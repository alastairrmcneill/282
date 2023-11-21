class Like {
  final String postId;
  final String userId;
  final String? userProfilePictureURL;
  final String userDisplayName;

  Like({
    required this.postId,
    required this.userId,
    required this.userProfilePictureURL,
    required this.userDisplayName,
  });
  Map<String, dynamic> toJSON() {
    return {
      LikeFields.postId: postId,
      LikeFields.userId: userId,
      LikeFields.userProfilePictureURL: userProfilePictureURL,
      LikeFields.userDisplayName: userDisplayName,
    };
  }

  static Like fromJSON(Map<String, dynamic> json) {
    return Like(
        postId: json[LikeFields.postId] as String,
        userId: json[LikeFields.userId] as String,
        userDisplayName: json[LikeFields.userDisplayName] as String? ?? "User",
        userProfilePictureURL: json[LikeFields.userProfilePictureURL] as String?);
  }
}

class LikeFields {
  static String postId = "postId";
  static String userId = "userId";
  static String userProfilePictureURL = "userProfilePictureURL";
  static String userDisplayName = "userDisplayName";
}
