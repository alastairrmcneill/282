import 'package:cloud_firestore/cloud_firestore.dart';

class MunroPicture {
  final String uid;
  final String munroId;
  final String imageUrl;
  final Timestamp dateTime;
  final String postId;

  MunroPicture({
    required this.uid,
    required this.munroId,
    required this.imageUrl,
    required this.dateTime,
    required this.postId,
  });

  factory MunroPicture.fromJSON(Map<String, dynamic> data) => MunroPicture(
        uid: data[MunroPictureFields.uid] as String,
        munroId: data[MunroPictureFields.munroId] as String,
        imageUrl: data[MunroPictureFields.imageUrl] as String,
        dateTime: data[MunroPictureFields.dateTime] as Timestamp,
        postId: data[MunroPictureFields.postId] as String,
      );
}

class MunroPictureFields {
  static const String uid = 'id';
  static const String munroId = 'munroId';
  static const String imageUrl = 'imageUrl';
  static const String dateTime = 'dateTime';
  static const String postId = 'postId';
}
