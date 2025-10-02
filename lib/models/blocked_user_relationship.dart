class BlockedUserRelationship {
  final String userId;
  final String blockedUserId;
  final DateTime dateTimeBlocked;

  BlockedUserRelationship({
    required this.userId,
    required this.blockedUserId,
    required this.dateTimeBlocked,
  });

  Map<String, dynamic> toJSON() {
    return {
      BlockedUserRelationshipFields.userId: userId,
      BlockedUserRelationshipFields.blockedUserId: blockedUserId,
      BlockedUserRelationshipFields.dateTimeBlocked: dateTimeBlocked.toIso8601String(),
    };
  }

  static BlockedUserRelationship fromJSON(Map<String, dynamic> json) {
    return BlockedUserRelationship(
      userId: json[BlockedUserRelationshipFields.userId] as String,
      blockedUserId: json[BlockedUserRelationshipFields.blockedUserId] as String,
      dateTimeBlocked: DateTime.parse(json[BlockedUserRelationshipFields.dateTimeBlocked] as String),
    );
  }
}

class BlockedUserRelationshipFields {
  static String userId = "user_id";
  static String blockedUserId = "blocked_user_id";
  static String dateTimeBlocked = "datetime_blocked";
}
