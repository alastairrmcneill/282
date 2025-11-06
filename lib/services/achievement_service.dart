import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class AchievementService {
  // Get UserAchievements
  static Future getUserAchievements(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);

    if (userState.currentUser == null) return;

    List<Achievement> allUserAchievements = await UserAchievementsDatabase.getUserAchievements(
      context,
      userId: userState.currentUser!.uid ?? "",
    );

    achievementsState.setAchievements = allUserAchievements;
    List<Achievement> achievementsToShow = allUserAchievements
        .where((achievement) => achievement.completed && achievement.acknowledgedAt == null)
        .toList();

    achievementsState.setRecentlyCompletedAchievements = achievementsToShow;

    List<Achievement> achievementsToReset = allUserAchievements
        .where((achievement) => !achievement.completed && achievement.acknowledgedAt != null)
        .toList();

    for (var achievement in achievementsToReset) {
      unacknowledgeAchievement(context, achievement: achievement);
    }
  }

  // Mark an achievement as acknowledged
  static Future<void> acknowledgeAchievement({required Achievement achievement}) async {
    try {
      achievement.acknowledgedAt = DateTime.now();
      await UserAchievementsDatabase.updateUserAchievement(achievement: achievement);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
    }
  }

  // Unmark an achievement as acknowledged
  static Future<void> unacknowledgeAchievement(BuildContext context, {required Achievement achievement}) async {
    try {
      achievement.acknowledgedAt = null;
      await UserAchievementsDatabase.updateUserAchievement(achievement: achievement);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
    }
  }

  // Set annual goal
  static Future<void> setMunroChallenge(BuildContext context) async {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);

    Achievement achievement = achievementsState.currentAchievement!;
    achievement.annualTarget = achievementsState.achievementFormCount;

    await UserAchievementsDatabase.updateUserAchievement(achievement: achievement);
  }
}
