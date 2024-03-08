class Achievement {
  final String uid;
  final String name;
  final String description;
  final String type;
  final bool completed;
  final Map criteria;

  Achievement({
    required this.uid,
    required this.name,
    required this.description,
    required this.type,
    required this.completed,
    required this.criteria,
  });

  Map<String, dynamic> toJSON() {
    return {
      AchievementFields.uid: uid,
      AchievementFields.name: name,
      AchievementFields.description: description,
      AchievementFields.type: type,
      AchievementFields.completed: completed,
      AchievementFields.criteria: criteria,
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
    );
  }

  Achievement copy({
    String? uid,
    String? name,
    String? description,
    String? type,
    bool? completed,
    Map? criteria,
  }) {
    return Achievement(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      completed: completed ?? this.completed,
      criteria: criteria ?? this.criteria,
    );
  }

  @override
  String toString() {
    return "Achievement: ${AchievementFields.uid}: $uid, ${AchievementFields.name}: $name, ${AchievementFields.description}: $description, ${AchievementFields.type}: $type, ${AchievementFields.completed}: $completed, ${AchievementFields.criteria}: $criteria";
  }
}

class AchievementFields {
  static const String uid = 'uid';
  static const String name = 'name';
  static const String description = 'description';
  static const String type = 'type';
  static const String completed = 'completed';
  static const String criteria = 'criteria';
}

class AchievementTypes {
  static const String totalCount = "totalCount";
}

class CriteriaFields {
  static const String count = "count";
}
