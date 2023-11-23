class Notif {
  final String uid;
  final String? postId;
  final String targetId;
  final String sourceId;
  final String sourceDisplayName;
  final String? sourceProfilePictureURL;
  final String type;

  Notif({
    required this.uid,
    required this.postId,
    required this.targetId,
    required this.sourceId,
    required this.sourceDisplayName,
    required this.sourceProfilePictureURL,
    required this.type,
  });

  // To JSON
  Map<String, dynamic> toJSON() {
    return {
      NotifFields.uid: uid,
      NotifFields.postId: postId,
      NotifFields.targetId: targetId,
      NotifFields.sourceId: sourceId,
      NotifFields.sourceDisplayName: sourceDisplayName,
      NotifFields.sourceProfilePictureURL: sourceProfilePictureURL,
      NotifFields.type: type,
    };
  }

  // From JSON
  static Notif fromJSON(Map<String, dynamic> json) {
    return Notif(
      uid: json[NotifFields.uid] as String,
      postId: json[NotifFields.postId] as String?,
      targetId: json[NotifFields.targetId] as String,
      sourceId: json[NotifFields.sourceId] as String,
      sourceDisplayName: json[NotifFields.sourceDisplayName] as String,
      sourceProfilePictureURL: json[NotifFields.sourceProfilePictureURL] as String?,
      type: json[NotifFields.type] as String,
    );
  }

  // Copy
  Notif copyWith({
    String? uid,
    String? postId,
    String? targetId,
    String? sourceId,
    String? sourceDisplayName,
    String? sourceProfilePictureURL,
    String? type,
  }) {
    return Notif(
      uid: uid ?? this.uid,
      postId: postId ?? this.postId,
      targetId: targetId ?? this.targetId,
      sourceId: sourceId ?? this.sourceId,
      sourceDisplayName: sourceDisplayName ?? this.sourceDisplayName,
      sourceProfilePictureURL: sourceProfilePictureURL ?? this.sourceProfilePictureURL,
      type: type ?? this.type,
    );
  }
}

class NotifFields {
  static String uid = "id";
  static String targetId = "targetId";
  static String sourceId = "sourceId";
  static String sourceDisplayName = "sourceDisplayName";
  static String sourceProfilePictureURL = "sourceProfilePictureURL";
  static String postId = "postId";
  static String type = "type";
}
