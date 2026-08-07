import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum ImageUploadType { profile, post }

class StorageRepository {
  final FirebaseStorage _storage;
  final Uuid _uuid;
  final Duration _uploadTimeout;
  final int _compressQuality;
  final int _maxUploadAttempts;

  StorageRepository(
    this._storage, {
    Uuid? uuid,
    Duration? uploadTimeout,
    int? compressQuality,
    int? maxUploadAttempts,
  })  : _uuid = uuid ?? const Uuid(),
        _uploadTimeout = uploadTimeout ?? const Duration(seconds: 10),
        _compressQuality = compressQuality ?? 50,
        _maxUploadAttempts = maxUploadAttempts ?? 2;

  Future<String> uploadImage({
    required File imageFile,
    required ImageUploadType type,
  }) async {
    String imageId = _uuid.v4();
    String compressedPath = await _compressImage(imageId, imageFile);

    final storagePath = switch (type) {
      ImageUploadType.profile => 'images/users/user_$imageId.jpg',
      ImageUploadType.post => 'images/posts/post_$imageId.jpg',
    };

    try {
      return await _uploadWithRetry(storagePath, compressedPath, type);
    } finally {
      try {
        final f = File(compressedPath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  Future<String> _uploadWithRetry(String storagePath, String localPath, ImageUploadType type) async {
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
      } catch (e) {
        // A slow/flaky connection can cause a single upload attempt to time
        // out or drop mid-transfer even though the network recovers a moment
        // later. Retry transient failures before surfacing them to the user
        // (and reporting them as an unresolved error) — a genuine failure
        // (bad file, permission error, etc.) still fails immediately.
        if (attempt >= _maxUploadAttempts || !_isRetryableUploadError(e)) rethrow;
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
