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
        case AchievementTypes.highestMunros:
          _checkHighestMunros(
            context,
            achievement: achievement,
            userState: userState,
            achievementsState: achievementsState,
          );
          break;
        case AchievementTypes.lowestMunros:
          _checkLowestMunros(
            context,
            achievement: achievement,
            userState: userState,
            achievementsState: achievementsState,
          );
          break;
        case AchievementTypes.monthlyMunro:
          _checkMonthlyMunro(
            context,
            achievement: achievement,
            userState: userState,
            achievementsState: achievementsState,
          );
          break;
        case AchievementTypes.multiMunroDay:
          _checkMultiMunroDay(
            context,
            achievement: achievement,
            userState: userState,
            achievementsState: achievementsState,
          );
          break;
        case AchievementTypes.areaGoal:
          _checkAreaGoal(
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
  static _checkTotalCount(
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

  // Highest Munros
  static _checkHighestMunros(
    BuildContext context, {
    required Achievement achievement,
    required UserState userState,
    required AchievementsState achievementsState,
  }) {
    // Get highest munros
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    List<Munro> munros = munroState.munroList;
    munros.sort((a, b) => b.feet - a.feet);

    int count = achievement.criteria[CriteriaFields.count] as int;

    List<Munro> highestMunros = munros.sublist(0, count);

    // Get my list of summits from highest x number
    int numSummited = highestMunros.where((munro) {
      // Get the personal data for this munro
      var personalMunroData = userState.currentUser?.personalMunroData?[int.parse(munro.id) - 1];

      // Check if the munro has been summited
      return personalMunroData?[MunroFields.summited] ?? false;
    }).length;

    // Compare to goal
    bool completed = numSummited >= count;

    // Update notifiers
    if (completed && !achievement.completed) {
      // Add to new notifier
      achievementsState.addRecentlyCompletedAchievement = achievement.copy(
        progress: numSummited,
        completed: true,
      );
    }

    // Add to regular notifier
    achievementsState.updateAchievement = achievement.copy(
      progress: numSummited,
      completed: completed,
    );
  }

  // Lowest Munros
  static _checkLowestMunros(
    BuildContext context, {
    required Achievement achievement,
    required UserState userState,
    required AchievementsState achievementsState,
  }) {
    // Get lowest munros
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    List<Munro> munros = munroState.munroList;
    munros.sort((a, b) => a.feet - b.feet);

    int count = achievement.criteria[CriteriaFields.count] as int;

    List<Munro> lowestMunros = munros.sublist(0, count);

    // Get my list of summits from highest x number
    int numSummited = lowestMunros.where((munro) {
      // Get the personal data for this munro
      var personalMunroData = userState.currentUser?.personalMunroData?[int.parse(munro.id) - 1];

      // Check if the munro has been summited
      return personalMunroData?[MunroFields.summited] ?? false;
    }).length;

    // Compare to goal
    bool completed = numSummited >= count;

    // Update notifiers
    if (completed && !achievement.completed) {
      // Add to new notifier
      achievementsState.addRecentlyCompletedAchievement = achievement.copy(
        progress: numSummited,
        completed: true,
      );
    }

    // Add to regular notifier
    achievementsState.updateAchievement = achievement.copy(
      progress: numSummited,
      completed: completed,
    );
  }

  // Monhtly Munros
  static _checkMonthlyMunro(
    BuildContext context, {
    required Achievement achievement,
    required UserState userState,
    required AchievementsState achievementsState,
  }) {
    // Get munros by month
    Map<int, int> monthCounts = {
      for (var i = 1; i <= 12; i++) i: 0,
    };

    userState.currentUser?.personalMunroData?.forEach((munroData) {
      Timestamp? summitedDate = munroData[MunroFields.summitedDate] as Timestamp?;

      if (summitedDate != null) {
        // Increment the count for the month of the summited date
        int month = summitedDate.toDate().month;
        monthCounts[month] = (monthCounts[month] ?? 0) + 1;
      }
    });

    int monthsWithCompletedMunro = monthCounts.values.where((int count) => count > 0).length;

    // Compare to goal
    bool completed = monthsWithCompletedMunro == 12;

    // Update notifiers
    if (completed && !achievement.completed) {
      // Add to new notifier
      achievementsState.addRecentlyCompletedAchievement = achievement.copy(
        progress: monthsWithCompletedMunro,
        completed: true,
      );
    }

    // Add to regular notifier
    achievementsState.updateAchievement = achievement.copy(
      progress: monthsWithCompletedMunro,
      completed: completed,
    );
  }

  // Multi Munro Day
  static _checkMultiMunroDay(
    BuildContext context, {
    required Achievement achievement,
    required UserState userState,
    required AchievementsState achievementsState,
  }) {
    // Get multi munro days
    Map<DateTime, int> dateCounts = {};

    userState.currentUser?.personalMunroData?.forEach((munro) {
      Timestamp? summitedDate = munro[MunroFields.summitedDate] as Timestamp?;

      if (summitedDate != null) {
        // Increment the count for the month of the summited date
        DateTime dateTime = summitedDate.toDate();
        DateTime date = DateTime(dateTime.year, dateTime.month, dateTime.day);

        dateCounts[date] = (dateCounts[date] ?? 0) + 1;
      }
    });

    int daysWithCorrectCount =
        dateCounts.values.where((int count) => count == achievement.criteria[CriteriaFields.count]).length;

    // Compare to goal
    bool completed = daysWithCorrectCount > 0;

    // Update notifiers
    if (completed && !achievement.completed) {
      // Add to new notifier
      achievementsState.addRecentlyCompletedAchievement = achievement.copy(
        completed: true,
      );
    }

    // Add to regular notifier
    achievementsState.updateAchievement = achievement.copy(
      completed: completed,
    );
  }

  // Area goal
  static _checkAreaGoal(
    BuildContext context, {
    required Achievement achievement,
    required UserState userState,
    required AchievementsState achievementsState,
  }) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    // Create a new list that combines personalMunroData and munroList
    List<Map<String, dynamic>> combinedList = userState.currentUser?.personalMunroData?.map((personalMunro) {
          // Find the matching munro in munroList
          var matchingMunro = munroState.munroList.firstWhere((munro) => munro.id == personalMunro['id']);

          // Combine the personalMunro and matchingMunro into a new map
          return {...personalMunro, ...matchingMunro.toJSON()};
        }).toList() ??
        [];

    // Get total completed
    int totalCompletedInArea = combinedList
        .where((element) => element[MunroFields.summited] as bool)
        .where(
            (element) => (element[MunroFields.area] as String) == (achievement.criteria[CriteriaFields.area] as String))
        .length;

    // Compare to goal
    bool completed = totalCompletedInArea >= achievement.criteria[CriteriaFields.count];

    // Update notifiers
    if (completed && !achievement.completed) {
      // Add to new notifier
      achievementsState.addRecentlyCompletedAchievement = achievement.copy(
        progress: totalCompletedInArea,
        completed: true,
      );
    }

    // Add to regular notifier
    achievementsState.updateAchievement = achievement.copy(
      progress: totalCompletedInArea,
      completed: completed,
    );
  }
}
