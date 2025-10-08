class Like {
  final String? uid;
  final String postId;
  final String userId;
  final String? userProfilePictureURL;
  final String userDisplayName;
  final DateTime dateTimeCreated;

  Like({
    this.uid,
    required this.postId,
    required this.userId,
    required this.userProfilePictureURL,
    required this.userDisplayName,
    required this.dateTimeCreated,
  });

  Map<String, dynamic> toJSON() {
    return {
      LikeFields.postId: postId,
      LikeFields.userId: userId,
      LikeFields.dateTimeCreated: dateTimeCreated.toIso8601String(),
    };
  }

  static Like fromJSON(Map<String, dynamic> json) {
    return Like(
        uid: json[LikeFields.uid] as String?,
        postId: json[LikeFields.postId] as String,
        userId: json[LikeFields.userId] as String,
        userDisplayName: json[LikeFields.userDisplayName] as String? ?? "User",
        userProfilePictureURL: json[LikeFields.userProfilePictureURL] as String?,
        dateTimeCreated: DateTime.parse(json[LikeFields.dateTimeCreated] as String));
  }

  Like copyWith({
    String? uid,
    String? postId,
    String? userId,
    String? userDisplayName,
    String? userProfilePictureURL,
    DateTime? dateTimeCreated,
  }) {
    return Like(
      uid: uid ?? this.uid,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userProfilePictureURL: userProfilePictureURL ?? this.userProfilePictureURL,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      dateTimeCreated: dateTimeCreated ?? this.dateTimeCreated,
    );
  }
}

class LikeFields {
  static String uid = "uid";
  static String postId = "post_id";
  static String userId = "user_id";
  static String userProfilePictureURL = "user_profile_picture_url";
  static String userDisplayName = "user_display_name";
  static String dateTimeCreated = "date_time_created";
}
