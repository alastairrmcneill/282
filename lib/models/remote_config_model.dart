class RemoteConfig {
  final int feedbackSurveyNumber;
  final String latestAppVersion;
  final int hardUpdateBuildNumber;
  final String whatsNew;
  final bool groupFilterNewIcon;

  const RemoteConfig({
    required this.feedbackSurveyNumber,
    required this.latestAppVersion,
    required this.hardUpdateBuildNumber,
    required this.whatsNew,
    required this.groupFilterNewIcon,
  });

  static RemoteConfig get defaultConfig => RemoteConfig(
        feedbackSurveyNumber: 0,
        latestAppVersion: "1.0.0",
        hardUpdateBuildNumber: 0,
        whatsNew: "No new features this time. We are working hard to bring you new features soon.",
        groupFilterNewIcon: true,
      );

  @override
  String toString() {
    return '''RemoteConfig(
                feedbackSurveyNumber: $feedbackSurveyNumber, 
                latestAppVersion: $latestAppVersion, 
                hardUpdateBuildNumber: $hardUpdateBuildNumber, 
                whatsNew: $whatsNew, 
                groupFilterNewIcon: $groupFilterNewIcon, 
              )''';
  }
}

class RCFields {
  static const feedbackSurveyNumber = "feedback_survey_number";
  static const latestAppVersion = "latest_app_version";
  static const hardUpdateBuildNumber = "hard_update_build_number";
  static const whatsNew = "whats_new";
  static const groupFilterNewIcon = "group_filter_new_icon";
}
