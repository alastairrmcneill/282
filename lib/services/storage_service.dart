import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:two_eight_two/services/log_service.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> _compressImage(String imageId, File image) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    XFile? compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/image_$imageId.jpg',
      quality: 50,
    );

    return compressedImageFile!.path;
  }

  static Future<String> _uploadImage(
    String path,
    String imageId,
    String imagePath,
  ) async {
    UploadTask uploadTask = _storage.ref().child(path).putFile(File(imagePath));

    TaskSnapshot storageSnap = await uploadTask.whenComplete(() => null);

    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  static Future<String> uploadProfilePicture(File imageFile) async {
    String imageId = Uuid().v4();

    String compressedImagePath = await _compressImage(imageId, imageFile);

    String downloadUrl = await _uploadImage(
      'images/users/user_$imageId.jpg',
      imageId,
      compressedImagePath,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () async {
        throw FirebaseException(
          plugin: "Storage",
          code: "Uploading your image timed out. Please try again later",
          message: "There was an issue with editing your profile picture, please try again later.",
        );
      },
    );
    return downloadUrl;
  }

  static Future<String> uploadPostImage(File imageFile) async {
    String imageId = Uuid().v4();

    String compressedImagePath = await _compressImage(imageId, imageFile);

    String downloadUrl = await _uploadImage(
      'images/posts/post_$imageId.jpg',
      imageId,
      compressedImagePath,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () async {
        throw FirebaseException(
          plugin: "Storage",
          code: "Uploading your image timed out. Please try again later",
          message: "There was an issue with your upload, please try again later.",
        );
      },
    );
    return downloadUrl;
  }

  /// Deletes an image from Firebase Storage using its download URL
  static Future<void> deleteImage(String imageURL) async {
    try {
      // Extract the file path from the URL and delete from Firebase Storage
      final ref = _storage.refFromURL(imageURL);
      await ref.delete();
    } catch (e) {
      Log.error("Failed to delete image: $imageURL", stackTrace: StackTrace.current);
      // Don't throw - we don't want to fail the entire edit operation if image deletion fails
    }
  }
}
