import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String? uid;
  final String postId;
  final String authorId;
  final String authorDisplayName;
  final String? authorProfilePictureURL;
  final DateTime dateTime;
  final String commentText;

  Comment({
    this.uid,
    required this.postId,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorProfilePictureURL,
    required this.dateTime,
    required this.commentText,
  });

  // To JSON
  Map<String, dynamic> toJSON() {
    return {
      CommentFields.uid: uid,
      CommentFields.postId: postId,
      CommentFields.authorId: authorId,
      CommentFields.authorDisplayName: authorDisplayName,
      CommentFields.authorProfilePictureURL: authorProfilePictureURL,
      CommentFields.dateTime: dateTime,
      CommentFields.commentText: commentText,
    };
  }

  // From JSON
  static Comment fromJSON(Map<String, dynamic> json) {
    return Comment(
      uid: json[CommentFields.uid] as String?,
      postId: json[CommentFields.postId] as String,
      authorId: json[CommentFields.authorId] as String,
      authorDisplayName: json[CommentFields.authorDisplayName] as String,
      authorProfilePictureURL: json[CommentFields.authorProfilePictureURL] as String?,
      dateTime: (json[CommentFields.dateTime] as Timestamp).toDate(),
      commentText: json[CommentFields.commentText] as String,
    );
  }

  // Copy
  Comment copyWith({
    String? uid,
    String? postId,
    String? authorId,
    String? authorDisplayName,
    String? authorProfilePictureURL,
    DateTime? dateTime,
    String? commentText,
  }) {
    return Comment(
      uid: uid ?? this.uid,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorProfilePictureURL: authorProfilePictureURL ?? this.authorProfilePictureURL,
      dateTime: dateTime ?? this.dateTime,
      commentText: commentText ?? this.commentText,
    );
  }
}

class CommentFields {
  static String uid = "uid";
  static String authorId = "authorId";
  static String authorDisplayName = "authorDisplayName";
  static String authorProfilePictureURL = "authorProfilePictureURL";
  static String dateTime = "dateTime";
  static String pictureURL = "pictureURL";
  static String commentText = "commentText";
  static String postId = "postId";
}
