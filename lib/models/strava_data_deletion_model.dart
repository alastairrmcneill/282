class StravaDataDeletion {
  final String id;
  final DateTime completedAt;
  final int activitiesDeleted;
  final int matchesDeleted;

  const StravaDataDeletion({
    required this.id,
    required this.completedAt,
    required this.activitiesDeleted,
    required this.matchesDeleted,
  });

  static StravaDataDeletion fromJSON(Map<String, dynamic> json) {
    return StravaDataDeletion(
      id: (json[StravaDataDeletionFields.id] ?? json[StravaDataDeletionFields.deletionId]) as String,
      completedAt: DateTime.parse(json[StravaDataDeletionFields.completedAt] as String),
      activitiesDeleted: json[StravaDataDeletionFields.activitiesDeleted] as int,
      matchesDeleted: json[StravaDataDeletionFields.matchesDeleted] as int,
    );
  }
}

class StravaDataDeletionFields {
  static const String id = 'id';
  static const String deletionId = 'deletion_id';
  static const String userId = 'user_id';
  static const String completedAt = 'completed_at';
  static const String activitiesDeleted = 'activities_deleted';
  static const String matchesDeleted = 'matches_deleted';
}
