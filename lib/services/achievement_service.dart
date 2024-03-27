import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AchievementService {
  // Get User Achievements
  static Future getUserAchievements(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);

    try {
      achievementsState.setStatus = AchievementsStatus.loading;

      List<Achievement> achievementList = [];

      if (userState.currentUser != null) {
        for (String key in userState.currentUser!.achievements?.keys ?? []) {
          Achievement achievement = Achievement.fromJSON(userState.currentUser!.achievements![key]);
          achievementList.add(achievement);
        }
      }
      achievementsState.setAchievements = achievementList;

      // Set status
      achievementsState.setStatus = AchievementsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      achievementsState.setError = Error(
        code: error.toString(),
        message: "There was an issue loading you achievement data",
      );
    }
  }

  // Update User Achievements
  static Future _updateUserAchievements(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);

    try {
      if (userState.currentUser != null) {
        for (Achievement achievement in achievementsState.achievements) {
          userState.currentUser!.achievements?[achievement.uid] = achievement.toJSON();
        }

        await UserService.updateUser(context, appUser: userState.currentUser!);
      }
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(
        context,
        message: "There was an error updating your achievements Please try again.",
      );
    }
  }

  // Set Munro Challenge data
  static Future setMunroChallenge(BuildContext context) async {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    if (userState.currentUser == null) return;

    if (achievementsState.currentAchievement == null) return;

    Achievement achievement = achievementsState.currentAchievement!;

    try {
      achievementsState.setStatus = AchievementsStatus.loading;

      // Check if achievement is already completed
      int totalCompleted =
          userState.currentUser?.personalMunroData?.where((element) => element[MunroFields.summited] as bool).length ??
              0;
      bool completed = totalCompleted >= achievement.criteria[CriteriaFields.count];

      Achievement newAchievement = achievement.copy(
        progress: totalCompleted,
        completed: completed,
      );

      // Update notifier
      achievementsState.updateAchievement = newAchievement;

      // Update database
      await _updateUserAchievements(context);

      // Set status
      achievementsState.setStatus = AchievementsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      achievementsState.setError = Error(
        code: error.toString(),
        message: "There was an issue setting you munro challenge.",
      );
    }
  }

  // Check if achievements are completed
  static checkAchievements(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: false);
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);

    for (Achievement achievement in achievementsState.achievements) {
      print("Achievement: ${achievement.name}");

      switch (achievement.type) {
        case AchievementTypes.totalCount:
          _checkTotalCount(
            context,
            achievement: achievement,
            userState: userState,
            achievementsState: achievementsState,
          );
          break;
        case AchievementTypes.annualGoal:
          _checkAnnualGoal(
            context,
            achievement: achievement,
            userState: userState,
            achievementsState: achievementsState,
          );
          break;
        default:
          break;
      }
    }

    // Update database
    _updateUserAchievements(context);
  }

  // All Time challenges
  static void _checkTotalCount(
    BuildContext context, {
    required Achievement achievement,
    required UserState userState,
    required AchievementsState achievementsState,
  }) {
    // Get total completed
    int totalCompleted =
        userState.currentUser?.personalMunroData?.where((element) => element[MunroFields.summited] as bool).length ?? 0;

    // Compare to goal
    bool completed = totalCompleted >= achievement.criteria[CriteriaFields.count];

    // Update notifiers
    if (completed && !achievement.completed) {
      // Add to new notifier
      achievementsState.addRecentlyCompletedAchievement = achievement.copy(
        progress: totalCompleted,
        completed: true,
      );
    }

    // Add to regular notifier
    achievementsState.updateAchievement = achievement.copy(
      progress: totalCompleted,
      completed: completed,
    );
  }

  // Annual goal challenges
  static _checkAnnualGoal(
    BuildContext context, {
    required Achievement achievement,
    required UserState userState,
    required AchievementsState achievementsState,
  }) {
    if (achievement.criteria[CriteriaFields.year] != DateTime.now().year) return;

    // Get total completed this year
    List munrosCompletedThisYear = userState.currentUser?.personalMunroData?.where((element) {
          bool summited = element[MunroFields.summited] as bool;
          if (!summited) return false;
          int achievementYear = achievement.criteria[CriteriaFields.year] as int;
          var summitedDate = element[MunroFields.summitedDate];
          if (summitedDate == null) return false;

          if (summitedDate is Timestamp) {
            summitedDate = summitedDate.toDate();
          }
          int summitedYear = summitedDate.year;

          return summited && summitedYear == achievementYear;
        }).toList() ??
        [];
    int completedThisYear = munrosCompletedThisYear.length;

    // Compare to goal
    bool completed = completedThisYear >= achievement.criteria[CriteriaFields.count];

    // Update notifiers
    if (completed && !achievement.completed) {
      // Add to new notifier
      achievementsState.addRecentlyCompletedAchievement = achievement.copy(
        progress: completedThisYear,
        completed: true,
      );
    }

    // Add to regular notifier
    achievementsState.updateAchievement = achievement.copy(
      progress: completedThisYear,
      completed: completed,
    );
  }
}
