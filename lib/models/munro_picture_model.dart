import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:two_eight_two/models/models.dart';

class MunroPicture {
  final String uid;
  final String munroId;
  final String authorId;
  final String imageUrl;
  final Timestamp dateTime;
  final String postId;
  final String privacy;

  MunroPicture({
    required this.uid,
    required this.munroId,
    required this.authorId,
    required this.imageUrl,
    required this.dateTime,
    required this.postId,
    required this.privacy,
  });

  factory MunroPicture.fromJSON(Map<String, dynamic> data) => MunroPicture(
        uid: data[MunroPictureFields.uid] as String,
        munroId: data[MunroPictureFields.munroId] as String,
        authorId: data[MunroPictureFields.authorId] as String? ?? '',
        imageUrl: data[MunroPictureFields.imageUrl] as String,
        dateTime: data[MunroPictureFields.dateTime] as Timestamp,
        postId: data[MunroPictureFields.postId] as String,
        privacy: data[MunroPictureFields.privacy] as String? ?? Privacy.public,
      );
}

class MunroPictureFields {
  static const String uid = 'id';
  static const String munroId = 'munroId';
  static const String authorId = 'authorId';
  static const String imageUrl = 'imageUrl';
  static const String dateTime = 'dateTime';
  static const String postId = 'postId';
  static const String privacy = 'privacy';
}
