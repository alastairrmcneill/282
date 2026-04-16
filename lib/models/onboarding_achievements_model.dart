class OnboardingAchievements {
  final String name;
  final String description;

  OnboardingAchievements({
    required this.name,
    required this.description,
  });

  factory OnboardingAchievements.fromMap(Map<String, dynamic> map) {
    return OnboardingAchievements(
      name: map[OnboardingAchievementsFields.name] ?? '',
      description: map[OnboardingAchievementsFields.description] ?? '',
    );
  }
}

class OnboardingAchievementsFields {
  static const String name = 'name';
  static const String description = 'description';
}
