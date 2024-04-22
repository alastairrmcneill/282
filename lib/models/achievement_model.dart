class Achievement {
  final String uid;
  final String name;
  final String description;
  final String type;
  final bool completed;
  final Map criteria;
  final int progress;

  Achievement({
    required this.uid,
    required this.name,
    required this.description,
    required this.type,
    required this.completed,
    required this.criteria,
    required this.progress,
  });

  Map<String, dynamic> toJSON() {
    return {
      AchievementFields.uid: uid,
      AchievementFields.name: name,
      AchievementFields.description: description,
      AchievementFields.type: type,
      AchievementFields.completed: completed,
      AchievementFields.criteria: criteria,
      AchievementFields.progress: progress,
    };
  }

  static Achievement fromJSON(Map<String, dynamic> data) {
    return Achievement(
      uid: data[AchievementFields.uid] as String,
      name: data[AchievementFields.name] as String,
      description: data[AchievementFields.description] as String,
      type: data[AchievementFields.type] as String,
      completed: data[AchievementFields.completed] as bool,
      criteria: data[AchievementFields.criteria] as Map,
      progress: data[AchievementFields.progress] as int? ?? 0,
    );
  }

  Achievement copy({
    String? uid,
    String? name,
    String? description,
    String? type,
    bool? completed,
    Map? criteria,
    int? progress,
  }) {
    return Achievement(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      completed: completed ?? this.completed,
      criteria: criteria ?? this.criteria,
      progress: progress ?? this.progress,
    );
  }

  @override
  String toString() {
    return """Achievement: ${AchievementFields.uid}: $uid, 
                          ${AchievementFields.name}: $name, 
                          ${AchievementFields.description}: $description, 
                          ${AchievementFields.type}: $type, 
                          ${AchievementFields.completed}: 
                          $completed, ${AchievementFields.criteria}: $criteria, 
                          ${AchievementFields.progress}: $progress""";
  }
}

class AchievementFields {
  static const String uid = 'uid';
  static const String name = 'name';
  static const String description = 'description';
  static const String type = 'type';
  static const String completed = 'completed';
  static const String criteria = 'criteria';
  static const String progress = 'progress';
}

class AchievementTypes {
  static const String totalCount = "totalCount";
  static const String annualGoal = "annualGoal";
  static const String highestMunros = "highestMunros";
  static const String lowestMunros = "lowestMunros";
  static const String monthlyMunro = "monthlyMunro";
  static const String multiMunroDay = "multiMunroDay";
  static const String areaGoal = "areaGoal";
}

class CriteriaFields {
  static const String count = "count";
  static const String status = "status";
  static const String year = "year";
  static const String area = "area";
}

class AnnualGoalStatus {
  static const String pending = "pending";
  static const String inProgress = "InProgress";
  static const String completed = "Completed";
}
