import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/repos/repos.dart';
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

  // Update User Achievement
  static Future _updateUserAchievement(BuildContext context, {required Achievement achievement}) async {
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      if (userState.currentUser != null) {
        userState.currentUser!.achievements![achievement.uid] = achievement.toJSON();

        await UserDatabase.update(context, appUser: userState.currentUser!);
      }
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error updating your achievement. Please try again.");
    }
  }

  static Future setMunroChallenge(BuildContext context) async {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    if (userState.currentUser == null) return;

    if (achievementsState.currentAchievement == null) return;

    Achievement achievement = achievementsState.currentAchievement!;

    try {
      achievementsState.setStatus = AchievementsStatus.loading;

      Achievement newAchievement = achievement.copy(
        completed: _checkAnnualGoal(context, achievement: achievement, userState: userState),
      );

      await _updateUserAchievement(context, achievement: newAchievement);

      achievementsState.updateAchievement = newAchievement;

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
      if (achievement.completed) {
        print('Achievement already completed: ${achievement.name}');
        continue;
      }

      switch (achievement.type) {
        case AchievementTypes.totalCount:
          _checkTotalCount(context, achievement: achievement, userState: userState);
          break;
        case AchievementTypes.annualGoal:
          _checkAnnualGoal(context, achievement: achievement, userState: userState);
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

  static bool _checkAnnualGoal(BuildContext context, {required Achievement achievement, required UserState userState}) {
    print("Checking annual goal");
    if (achievement.criteria[CriteriaFields.year] != DateTime.now().year) {
      print("Not this year");
      return false;
    }

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

    print("Total completed in goal year: ${munrosCompletedThisYear.length}");
    print("Goal count: ${achievement.criteria[CriteriaFields.count]}");
    if (munrosCompletedThisYear.length >= achievement.criteria[CriteriaFields.count]) {
      _markAsCompleted(context, achievement: achievement);
      return true;
    } else {
      return false;
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
