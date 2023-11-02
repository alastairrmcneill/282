class FollowingRelationship {
  final String? uid;
  final String sourceId;
  final String targetId;
  final String targetDisplayName;
  final String? targetProfilePictureURL;

  FollowingRelationship({
    this.uid,
    required this.sourceId,
    required this.targetId,
    required this.targetDisplayName,
    required this.targetProfilePictureURL,
  });

  Map<String, dynamic> toJSON() {
    return {
      FollowingRelationshipFields.uid: uid,
      FollowingRelationshipFields.sourceId: sourceId,
      FollowingRelationshipFields.targetId: targetId,
      FollowingRelationshipFields.targetDisplayName: targetDisplayName,
      FollowingRelationshipFields.targetProfilePictureURL: targetProfilePictureURL,
    };
  }

  static FollowingRelationship fromJSON(Map<String, dynamic> json) {
    return FollowingRelationship(
        uid: json[FollowingRelationshipFields.uid] as String?,
        sourceId: json[FollowingRelationshipFields.sourceId] as String,
        targetId: json[FollowingRelationshipFields.targetId] as String,
        targetDisplayName: json[FollowingRelationshipFields.targetDisplayName] as String,
        targetProfilePictureURL: json[FollowingRelationshipFields.targetProfilePictureURL] as String?);
  }

  FollowingRelationship copyWith({
    String? uid,
    String? sourceId,
    String? targetId,
    String? targetDisplayName,
    String? targetProfilePictureURL,
  }) {
    return FollowingRelationship(
      uid: uid ?? this.uid,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      targetDisplayName: targetDisplayName ?? this.targetDisplayName,
      targetProfilePictureURL: targetDisplayName ?? this.targetDisplayName,
    );
  }

  @override
  String toString() =>
      'FollowingRelationship(uid: $uid, sourceId: $sourceId, targetId: $targetId, targetDisplayName: $targetDisplayName, targetProfilePictureURL: $targetProfilePictureURL)';
}

class FollowingRelationshipFields {
  static String uid = "uid";
  static String sourceId = "sourceId";
  static String targetId = "targetId";
  static String targetDisplayName = "targetDisplayName";
  static String targetProfilePictureURL = "targetProfilePictureURL";
}
