class FollowingRelationship {
  final String? uid;
  final String sourceId;
  final String targetId;
  final String targetDisplayName;
  final String? targetProfilePictureURL;
  final String sourceDisplayName;
  final String? sourceProfilePictureURL;

  FollowingRelationship({
    this.uid,
    required this.sourceId,
    required this.targetId,
    required this.targetDisplayName,
    required this.targetProfilePictureURL,
    required this.sourceDisplayName,
    required this.sourceProfilePictureURL,
  });

  Map<String, dynamic> toJSON() {
    return {
      FollowingRelationshipFields.uid: uid,
      FollowingRelationshipFields.sourceId: sourceId,
      FollowingRelationshipFields.targetId: targetId,
      FollowingRelationshipFields.targetDisplayName: targetDisplayName,
      FollowingRelationshipFields.targetProfilePictureURL: targetProfilePictureURL,
      FollowingRelationshipFields.sourceDisplayName: sourceDisplayName,
      FollowingRelationshipFields.sourceProfilePictureURL: sourceProfilePictureURL,
    };
  }

  static FollowingRelationship fromJSON(Map<String, dynamic> json) {
    return FollowingRelationship(
      uid: json[FollowingRelationshipFields.uid] as String?,
      sourceId: json[FollowingRelationshipFields.sourceId] as String,
      targetId: json[FollowingRelationshipFields.targetId] as String,
      targetDisplayName: json[FollowingRelationshipFields.targetDisplayName] as String,
      targetProfilePictureURL: json[FollowingRelationshipFields.targetProfilePictureURL] as String?,
      sourceDisplayName: json[FollowingRelationshipFields.sourceDisplayName] as String,
      sourceProfilePictureURL: json[FollowingRelationshipFields.sourceProfilePictureURL] as String?,
    );
  }

  FollowingRelationship copyWith({
    String? uid,
    String? sourceId,
    String? targetId,
    String? targetDisplayName,
    String? targetProfilePictureURL,
    String? sourceDisplayName,
    String? sourceProfilePictureURL,
  }) {
    return FollowingRelationship(
      uid: uid ?? this.uid,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      targetDisplayName: targetDisplayName ?? this.targetDisplayName,
      targetProfilePictureURL: targetProfilePictureURL ?? this.targetProfilePictureURL,
      sourceDisplayName: sourceDisplayName ?? this.sourceDisplayName,
      sourceProfilePictureURL: sourceProfilePictureURL ?? this.sourceProfilePictureURL,
    );
  }

  @override
  String toString() =>
      'FollowingRelationship(uid: $uid, sourceId: $sourceId, targetId: $targetId, targetDisplayName: $targetDisplayName, targetProfilePictureURL: $targetProfilePictureURL, sourceDisplayName: $sourceDisplayName, sourceProfilePictureURL: $sourceProfilePictureURL)';
}

class FollowingRelationshipFields {
  static String uid = "uid";
  static String sourceId = "sourceId";
  static String targetId = "targetId";
  static String targetDisplayName = "targetDisplayName";
  static String targetProfilePictureURL = "targetProfilePictureURL";
  static String sourceDisplayName = 'sourceDisplayName';
  static String sourceProfilePictureURL = 'sourceProfilePictureURL';
}
