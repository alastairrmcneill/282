class FollowingRelationship {
  final String sourceId;
  final String targetId;
  final String? targetDisplayName;
  final String? targetProfilePictureURL;
  final String? targetSearchName;
  final String? sourceDisplayName;
  final String? sourceProfilePictureURL;

  FollowingRelationship({
    required this.sourceId,
    required this.targetId,
    this.targetDisplayName,
    this.targetProfilePictureURL,
    this.targetSearchName,
    this.sourceDisplayName,
    this.sourceProfilePictureURL,
  });

  Map<String, dynamic> toJSON() {
    return {
      FollowingRelationshipFields.sourceId: sourceId,
      FollowingRelationshipFields.targetId: targetId,
    };
  }

  static FollowingRelationship fromJSON(Map<String, dynamic> json) {
    return FollowingRelationship(
      sourceId: json[FollowingRelationshipFields.sourceId] as String,
      targetId: json[FollowingRelationshipFields.targetId] as String,
      targetDisplayName: json[FollowingRelationshipFields.targetDisplayName] as String,
      targetProfilePictureURL: json[FollowingRelationshipFields.targetProfilePictureURL] as String?,
      targetSearchName: json[FollowingRelationshipFields.targetSearchName] as String? ??
          json[FollowingRelationshipFields.targetDisplayName] as String,
      sourceDisplayName: json[FollowingRelationshipFields.sourceDisplayName] as String,
      sourceProfilePictureURL: json[FollowingRelationshipFields.sourceProfilePictureURL] as String?,
    );
  }

  FollowingRelationship copyWith({
    String? sourceId,
    String? targetId,
    String? targetDisplayName,
    String? targetProfilePictureURL,
    String? targetSearchName,
    String? sourceDisplayName,
    String? sourceProfilePictureURL,
  }) {
    return FollowingRelationship(
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      targetDisplayName: targetDisplayName ?? this.targetDisplayName,
      targetProfilePictureURL: targetProfilePictureURL ?? this.targetProfilePictureURL,
      targetSearchName: targetSearchName ?? this.targetSearchName,
      sourceDisplayName: sourceDisplayName ?? this.sourceDisplayName,
      sourceProfilePictureURL: sourceProfilePictureURL ?? this.sourceProfilePictureURL,
    );
  }

  @override
  String toString() =>
      'FollowingRelationship(sourceId: $sourceId, targetId: $targetId, targetDisplayName: $targetDisplayName, targetSearchName: $targetSearchName, targetProfilePictureURL: $targetProfilePictureURL, sourceDisplayName: $sourceDisplayName, sourceProfilePictureURL: $sourceProfilePictureURL)';
}

class FollowingRelationshipFields {
  static String sourceId = "source_id";
  static String targetId = "target_id";
  static String targetDisplayName = "target_display_name";
  static String targetProfilePictureURL = "target_profile_picture_url";
  static String targetSearchName = "target_search_name";
  static String sourceDisplayName = 'source_display_name';
  static String sourceProfilePictureURL = 'source_profile_picture_url';
}
