class Achievement {
  String userId;
  String achievementId;
  DateTime dateTimeCreated;
  String name;
  String description;
  String type;
  String? criteriaValue;
  int? criteriaCount;
  int? annualTarget;
  DateTime? acknowledgedAt;
  int progress;
  bool completed;

  Achievement({
    required this.userId,
    required this.achievementId,
    required this.dateTimeCreated,
    required this.name,
    required this.description,
    required this.type,
    this.criteriaValue,
    this.criteriaCount,
    this.annualTarget,
    this.acknowledgedAt,
    required this.progress,
    required this.completed,
  });

  Map<String, dynamic> toJSON() {
    return {
      AchievementFields.userId: userId,
      AchievementFields.achievementId: achievementId,
      AchievementFields.annualTarget: annualTarget,
      AchievementFields.acknowledgedAt: acknowledgedAt?.toIso8601String(),
    };
  }

  static Achievement fromJSON(Map<String, dynamic> data) {
    return Achievement(
      userId: data[AchievementFields.userId] as String,
      achievementId: data[AchievementFields.achievementId] as String,
      name: data[AchievementFields.name] as String,
      dateTimeCreated: DateTime.parse(data[AchievementFields.dateTimeCreated] as String),
      description: data[AchievementFields.description] as String,
      type: data[AchievementFields.type] as String,
      criteriaValue: data[AchievementFields.criteriaValue] as String?,
      criteriaCount: data[AchievementFields.criteriaCount] as int?,
      annualTarget: data[AchievementFields.annualTarget] as int?,
      acknowledgedAt: data[AchievementFields.acknowledgedAt] != null
          ? DateTime.parse(data[AchievementFields.acknowledgedAt] as String)
          : null,
      progress: data[AchievementFields.progress] as int? ?? 0,
      completed: data[AchievementFields.completed] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return """Achievement: ${AchievementFields.userId}: $userId, 
                          ${AchievementFields.achievementId}: $achievementId,
                          ${AchievementFields.name}: $name, 
                          ${AchievementFields.dateTimeCreated}: $dateTimeCreated,
                          ${AchievementFields.description}: $description, 
                          ${AchievementFields.type}: $type, 
                          ${AchievementFields.criteriaValue}: $criteriaValue,
                          ${AchievementFields.criteriaCount}: $criteriaCount,
                          ${AchievementFields.annualTarget}: $annualTarget,
                          ${AchievementFields.acknowledgedAt}: $acknowledgedAt,
                          ${AchievementFields.progress}: $progress,
                          ${AchievementFields.completed}: $completed""";
  }
}

class AchievementFields {
  static const String userId = 'user_id';
  static const String achievementId = 'achievement_id';
  static const String name = 'name';
  static const String description = 'description';
  static const String type = 'type';
  static const String criteriaValue = 'criteria_value';
  static const String criteriaCount = 'criteria_count';
  static const String annualTarget = 'annual_target';
  static const String acknowledgedAt = 'acknowledged_at';
  static const String progress = 'progress';
  static const String completed = 'completed';
  static const String dateTimeCreated = 'date_time_created';
}

class AchievementTypes {
  static const String totalCount = "totalCount";
  static const String annualGoal = "annualGoal";
  static const String highestMunros = "highestMunros";
  static const String lowestMunros = "lowestMunros";
  static const String monthlyMunro = "monthlyMunro";
  static const String multiMunroDay = "multiMunroDay";
  static const String areaGoal = "areaGoal";
  static const String nameGoal = "nameGoal";
}
