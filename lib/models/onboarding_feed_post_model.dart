class OnboardingFeedPostModel {
  final String id;
  final String displayName;
  final String munroName;
  final String profilePictureUrl;
  final DateTime dateTimeCreated;

  OnboardingFeedPostModel({
    required this.id,
    required this.displayName,
    required this.munroName,
    required this.profilePictureUrl,
    required this.dateTimeCreated,
  });

  factory OnboardingFeedPostModel.fromMap(Map<String, dynamic> map) {
    return OnboardingFeedPostModel(
      id: map[OnboardingFeedPostFields.id] ?? '',
      displayName: map[OnboardingFeedPostFields.displayName] ?? '',
      munroName: map[OnboardingFeedPostFields.munroName] ?? '',
      profilePictureUrl: map[OnboardingFeedPostFields.profilePictureUrl] ?? '',
      dateTimeCreated:
          DateTime.parse(map[OnboardingFeedPostFields.dateTimeCreated] ?? DateTime.now().toIso8601String()),
    );
  }
}

class OnboardingFeedPostFields {
  static const String id = 'id';
  static const String displayName = 'display_name';
  static const String munroName = 'name';
  static const String profilePictureUrl = 'profile_picture_url';
  static const String dateTimeCreated = 'date_time_created';
}
