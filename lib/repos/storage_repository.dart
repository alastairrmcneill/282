import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:two_eight_two/logging/logging.dart';

enum ImageUploadType { profile, post }

class StorageRepository {
  final FirebaseStorage _storage;
  final Logger _logger;
  final Uuid _uuid;
  final Duration _uploadTimeout;
  final Duration _retryDelay;
  final int _compressQuality;
  final int _maxUploadAttempts;

  StorageRepository(
    this._storage,
    this._logger, {
    Uuid? uuid,
    Duration? uploadTimeout,
    Duration? retryDelay,
    int? compressQuality,
    int? maxUploadAttempts,
  })  : _uuid = uuid ?? const Uuid(),
        _uploadTimeout = uploadTimeout ?? const Duration(seconds: 10),
        _retryDelay = retryDelay ?? const Duration(milliseconds: 500),
        _compressQuality = compressQuality ?? 50,
        _maxUploadAttempts = maxUploadAttempts ?? 2;

  Future<String> uploadImage({
    required File imageFile,
    required ImageUploadType type,
  }) async {
    String imageId = _uuid.v4();
    final originalBytes = await imageFile.length();
    String compressedPath = await _compressImage(imageId, imageFile);
    final compressedBytes = await File(compressedPath).length();

    final storagePath = switch (type) {
      ImageUploadType.profile => 'images/users/user_$imageId.jpg',
      ImageUploadType.post => 'images/posts/post_$imageId.jpg',
    };

    try {
      return await _uploadWithRetry(storagePath, compressedPath, type, compressedBytes, originalBytes);
    } finally {
      try {
        final f = File(compressedPath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  Future<String> _uploadWithRetry(
    String storagePath,
    String localPath,
    ImageUploadType type,
    int compressedBytes,
    int originalBytes,
  ) async {
    final stopwatch = Stopwatch()..start();
    for (var attempt = 1; ; attempt++) {
      try {
        return await _uploadFile(storagePath, localPath).timeout(_uploadTimeout, onTimeout: () {
          throw FirebaseException(
            plugin: "Storage",
            code: "timeout",
            message: type == ImageUploadType.profile
                ? "There was an issue with editing your profile picture, please try again later."
                : "There was an issue with your upload, please try again later.",
          );
        });
      } catch (e, stackTrace) {
        final context = {
          'storage_path': storagePath,
          'upload_type': type.name,
          'attempt': attempt,
          'max_attempts': _maxUploadAttempts,
          'elapsed_ms': stopwatch.elapsedMilliseconds,
          'timeout_ms': _uploadTimeout.inMilliseconds,
          'original_bytes': originalBytes,
          'compressed_bytes': compressedBytes,
        };

        // A slow/flaky connection can cause a single upload attempt to time
        // out or drop mid-transfer even though the network recovers a moment
        // later. Retry transient failures before surfacing them to the user
        // (and reporting them as an unresolved error) — a genuine failure
        // (bad file, permission error, etc.) still fails immediately.
        final willRetry = attempt < _maxUploadAttempts && _isRetryableUploadError(e);
        if (willRetry) {
          _logger.info('Image upload attempt failed, retrying', context: {...context, 'error': e.toString()});
          // Retrying immediately into a connection that's still congested
          // (e.g. mid a batch of concurrent uploads) tends to just fail
          // again — back off briefly first.
          await Future.delayed(_retryDelay * attempt);
          continue;
        }

        _logger.error('Image upload failed', error: e, stackTrace: stackTrace, context: context);
        rethrow;
      }
    }
  }

  bool _isRetryableUploadError(Object error) {
    if (error is FirebaseException && error.code == 'timeout') return true;

    final message = error.toString().toLowerCase();
    const transientMarkers = [
      'socketexception',
      'clientexception',
      'handshakeexception',
      'connection closed',
      'connection reset',
      'connection terminated',
      'connection refused',
      'operation timed out',
      "can't assign requested address",
      'failed host lookup',
      'software caused connection abort',
    ];
    return transientMarkers.any(message.contains);
  }

  Future<void> deleteByUrl(String imageUrl) async {
    final ref = _storage.refFromURL(imageUrl);
    await ref.delete();
  }

  Future<String> _compressImage(String imageId, File image) async {
    final tempDir = await getTemporaryDirectory();
    final outPath = '${tempDir.path}/image_$imageId.jpg';

    final xfile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      outPath,
      quality: _compressQuality,
    );

    if (xfile == null) {
      throw StateError('Image compression failed (returned null).');
    }
    return xfile.path;
  }

  Future<String> _uploadFile(String storagePath, String localPath) async {
    final uploadTask = _storage.ref().child(storagePath).putFile(File(localPath));
    final snap = await uploadTask.whenComplete(() => null);
    return snap.ref.getDownloadURL();
  }
}
