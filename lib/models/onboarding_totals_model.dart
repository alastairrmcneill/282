class OnboardingTotalsModel {
  final int totalUsers;
  final int totalMunroCompletions;

  OnboardingTotalsModel({
    required this.totalUsers,
    required this.totalMunroCompletions,
  });

  factory OnboardingTotalsModel.fromMap(Map<String, dynamic> map) {
    return OnboardingTotalsModel(
      totalUsers: map[OnboardingTotalsFields.totalUsers] ?? 0,
      totalMunroCompletions: map[OnboardingTotalsFields.totalMunroCompletions] ?? 0,
    );
  }
}

class OnboardingTotalsFields {
  static const String totalUsers = 'total_users';
  static const String totalMunroCompletions = 'total_munro_completions';
}
