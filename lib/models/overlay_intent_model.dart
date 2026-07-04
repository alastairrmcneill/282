import 'package:two_eight_two/models/models.dart';

sealed class OverlayIntent {
  const OverlayIntent();

  String get dedupeKey;
}

final class HardUpdateDialogIntent extends OverlayIntent {
  const HardUpdateDialogIntent();

  @override
  String get dedupeKey => 'hard_update_dialog';
}

final class SoftUpdateDialogIntent extends OverlayIntent {
  final String currentVersion;
  final String latestVersion;
  final String whatsNew;

  const SoftUpdateDialogIntent({
    required this.currentVersion,
    required this.latestVersion,
    required this.whatsNew,
  });

  @override
  String get dedupeKey => 'soft_update_dialog';
}

final class WhatsNewDialogIntent extends OverlayIntent {
  final String version;

  const WhatsNewDialogIntent({required this.version});

  @override
  String get dedupeKey => 'whats_new_dialog';
}

final class FeedbackSurveyIntent extends OverlayIntent {
  final int surveyNumber;
  const FeedbackSurveyIntent({required this.surveyNumber});

  @override
  String get dedupeKey => 'feedback_survey';
}

final class AchievementCompleteIntent extends OverlayIntent {
  final List<Achievement> achievements;
  const AchievementCompleteIntent({required this.achievements});

  @override
  String get dedupeKey => 'achievement_complete:${achievements.map((a) => a.achievementId).join(",")}';
}

final class BulkMunroUpdateDialogIntent extends OverlayIntent {
  const BulkMunroUpdateDialogIntent();

  @override
  String get dedupeKey => 'bulk_munro_update_dialog';
}

final class AnnualMunroChallengeDialogIntent extends OverlayIntent {
  final Achievement achievement;
  const AnnualMunroChallengeDialogIntent({required this.achievement});

  @override
  String get dedupeKey => 'annual_munro_challenge_dialog';
}
