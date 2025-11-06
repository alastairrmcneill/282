class Notif {
  final String uid;
  final String? postId;
  final String targetId;
  final String sourceId;
  final String sourceDisplayName;
  final String? sourceProfilePictureURL;
  final String type;
  final DateTime dateTime;
  bool read;

  Notif({
    required this.uid,
    required this.postId,
    required this.targetId,
    required this.sourceId,
    required this.sourceDisplayName,
    required this.sourceProfilePictureURL,
    required this.type,
    required this.dateTime,
    required this.read,
  });

  // To JSON
  Map<String, dynamic> toJSON() {
    return {
      NotifFields.uid: uid,
      NotifFields.postId: postId,
      NotifFields.targetId: targetId,
      NotifFields.sourceId: sourceId,
      NotifFields.type: type,
      NotifFields.dateTime: dateTime.toIso8601String(),
      NotifFields.read: read,
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
      dateTime: DateTime.parse(json[NotifFields.dateTime] as String),
      read: json[NotifFields.read] as bool? ?? false,
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
    DateTime? dateTime,
    bool? read,
  }) {
    return Notif(
        uid: uid ?? this.uid,
        postId: postId ?? this.postId,
        targetId: targetId ?? this.targetId,
        sourceId: sourceId ?? this.sourceId,
        sourceDisplayName: sourceDisplayName ?? this.sourceDisplayName,
        sourceProfilePictureURL: sourceProfilePictureURL ?? this.sourceProfilePictureURL,
        type: type ?? this.type,
        dateTime: dateTime ?? this.dateTime,
        read: read ?? this.read);
  }
}

class NotifFields {
  static String uid = "id";
  static String targetId = "target_id";
  static String sourceId = "source_id";
  static String sourceDisplayName = "source_display_name";
  static String sourceProfilePictureURL = "source_profile_picture_url";
  static String postId = "post_id";
  static String type = "type";
  static String dateTime = "date_time_created";
  static String read = "read";
}
