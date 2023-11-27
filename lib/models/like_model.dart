class Like {
  final String? uid;
  final String postId;
  final String userId;
  final String? userProfilePictureURL;
  final String userDisplayName;

  Like({
    this.uid,
    required this.postId,
    required this.userId,
    required this.userProfilePictureURL,
    required this.userDisplayName,
  });
  Map<String, dynamic> toJSON() {
    return {
      LikeFields.uid: uid,
      LikeFields.postId: postId,
      LikeFields.userId: userId,
      LikeFields.userProfilePictureURL: userProfilePictureURL,
      LikeFields.userDisplayName: userDisplayName,
    };
  }

  static Like fromJSON(Map<String, dynamic> json) {
    return Like(
        uid: json[LikeFields.uid] as String?,
        postId: json[LikeFields.postId] as String,
        userId: json[LikeFields.userId] as String,
        userDisplayName: json[LikeFields.userDisplayName] as String? ?? "User",
        userProfilePictureURL: json[LikeFields.userProfilePictureURL] as String?);
  }

  Like copyWith({
    String? uid,
    String? postId,
    String? userId,
    String? userDisplayName,
    String? userProfilePictureURL,
  }) {
    return Like(
      uid: uid ?? this.uid,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userProfilePictureURL: userProfilePictureURL ?? this.userProfilePictureURL,
      userDisplayName: userDisplayName ?? this.userDisplayName,
    );
  }
}

class LikeFields {
  static String uid = "uid";
  static String postId = "postId";
  static String userId = "userId";
  static String userProfilePictureURL = "userProfilePictureURL";
  static String userDisplayName = "userDisplayName";
}
