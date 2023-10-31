import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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
    );
    return downloadUrl;
  }
}
