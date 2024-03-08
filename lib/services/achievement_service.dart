import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AchievementService {
  // Get User Achievements
  static Future getUserAchievements(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);

    try {
      achievementsState.setStatus = AchievementsStatus.loading;

      List<Achievement> achievements = await AchievementDatabase.readAllUserAchievements(
        context,
        userUid: userState.currentUser?.uid ?? "",
      );

      achievementsState.setAchievements = achievements;

      achievementsState.setStatus = AchievementsStatus.loaded;
    } catch (error) {
      achievementsState.setError = Error(
        code: error.toString(),
        message: "There was an error fetching your achievements. Please try again.",
      );
    }
  }

  // Get profile achievements
  static Future getProfileAchievements(BuildContext context) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);

    try {
      achievementsState.setStatus = AchievementsStatus.loading;

      List<Achievement> achievements = await AchievementDatabase.readAllUserAchievements(
        context,
        userUid: profileState.user?.uid ?? "",
      );

      achievementsState.setAchievements = achievements;

      achievementsState.setStatus = AchievementsStatus.loaded;
    } catch (error) {
      achievementsState.setError = Error(
        code: error.toString(),
        message: "There was an error fetching the user's achievements. Please try again.",
      );
    }
  }

  // Update User Achievement
  static Future _updateUserAchievement(BuildContext context, {required Achievement achievement}) async {
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      await AchievementDatabase.updateUserAchievement(
        context,
        userUid: userState.currentUser?.uid ?? "",
        achievement: achievement,
      );
    } catch (error) {
      showErrorDialog(context, message: "There was an error updating your achievement. Please try again.");
    }
  }

  // Check if achievements are completed
  static checkAchievements(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: false);
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);

    for (Achievement achievement in achievementsState.achievements) {
      if (achievement.completed) {
        print('Achievement already completed: ${achievement.name}');
        continue;
      }

      print('Checking achievement: ${achievement.name}');
      switch (achievement.type) {
        case AchievementTypes.totalCount:
          _checkTotalCount(context, achievement: achievement, userState: userState);
          break;
        default:
          break;
      }
    }
  }

  static void _checkTotalCount(BuildContext context, {required Achievement achievement, required UserState userState}) {
    int totalCompleted =
        userState.currentUser?.personalMunroData?.where((element) => element[MunroFields.summited] as bool).length ?? 0;
    print("Total completed: $totalCompleted");
    print(
        "totalCompleted >= achievement.criteria[CriteriaFields.count]: ${totalCompleted >= achievement.criteria[CriteriaFields.count]}");
    if (totalCompleted >= achievement.criteria[CriteriaFields.count]) {
      print("Achievement completed: ${achievement.name}");
      _markAsCompleted(context, achievement: achievement);
    }
  }

  static void _markAsCompleted(BuildContext context, {required Achievement achievement}) {
    Achievement newAchievement = achievement.copy(completed: true);

    // Update notifier
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
    achievementsState.updateAchievement = newAchievement;
    print("Updated notifier");

    // Add to new notifier
    achievementsState.addRecentlyCompletedAchievement = newAchievement;
    print("Added to new notifier");

    // Update database
    _updateUserAchievement(context, achievement: newAchievement);
    print("Updating database");
  }
}
