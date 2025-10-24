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
      CommentFields.postId: postId,
      CommentFields.authorId: authorId,
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
      dateTime: DateTime.parse(json[CommentFields.dateTime] as String),
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
  static String uid = "id";
  static String authorId = "author_id";
  static String authorDisplayName = "author_display_name";
  static String authorProfilePictureURL = "author_profile_picture_url";
  static String dateTime = "date_time_created";
  static String pictureURL = "picture_url";
  static String commentText = "text";
  static String postId = "post_id";
}
