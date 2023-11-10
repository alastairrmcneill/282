import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? uid;
  final String authorId;
  final String authorDisplayName;
  final String? authorProfilePictureURL;
  final DateTime dateTime;
  final String? pictureURL;
  final String? caption;
  final int likes;

  Post({
    this.uid,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorProfilePictureURL,
    required this.dateTime,
    this.pictureURL,
    this.caption,
    required this.likes,
  });

  // To JSON
  Map<String, dynamic> toJSON() {
    return {
      PostFields.uid: uid,
      PostFields.authorId: authorId,
      PostFields.authorDisplayName: authorDisplayName,
      PostFields.authorProfilePictureURL: authorProfilePictureURL,
      PostFields.dateTime: dateTime,
      PostFields.pictureURL: pictureURL,
      PostFields.caption: caption,
      PostFields.likes: likes,
    };
  }

  // From JSON
  static Post fromJSON(Map<String, dynamic> json) {
    return Post(
      uid: json[PostFields.uid] as String?,
      authorId: json[PostFields.authorId] as String,
      authorDisplayName: json[PostFields.authorDisplayName] as String,
      authorProfilePictureURL: json[PostFields.authorProfilePictureURL] as String?,
      dateTime: (json[PostFields.dateTime] as Timestamp).toDate(),
      pictureURL: json[PostFields.pictureURL] as String?,
      caption: json[PostFields.caption] as String?,
      likes: json[PostFields.likes] as int,
    );
  }

  // Copy
  Post copyWith({
    String? uid,
    String? authorId,
    String? authorDisplayName,
    String? authorProfilePictureURL,
    DateTime? dateTime,
    String? pictureURL,
    String? caption,
    int? likes,
  }) {
    return Post(
      uid: uid ?? this.uid,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorProfilePictureURL: authorProfilePictureURL ?? this.authorProfilePictureURL,
      dateTime: dateTime ?? this.dateTime,
      pictureURL: pictureURL ?? this.pictureURL,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
    );
  }
}

class PostFields {
  static String uid = "uid";
  static String authorId = "authorId";
  static String authorDisplayName = "authorDisplayName";
  static String authorProfilePictureURL = "authorProfilePictureURL";
  static String dateTime = "dateTime";
  static String pictureURL = "pictureURL";
  static String caption = "caption";
  static String likes = "likes";
}
