import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/services/services.dart';

class MunroService {
  static Future<void> loadMunroData(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    try {
      munroState.setStatus = MunroStatus.loading;

      // Load in munro data
      List<Munro> munroList = [];
      munroList = await MunroDatabase.loadBasicMunroData(context);

      if (userState.currentUser != null) {
        // Add personal munro data
        var dictMap = {for (var dict in userState.currentUser!.personalMunroData!) dict['id']: dict};

        // Iterate over the list of Munro objects and update them
        for (var munro in munroList) {
          var correspondingDict = dictMap[munro.id];
          if (correspondingDict != null) {
            List<dynamic> summitedDatesRaw = correspondingDict[MunroFields.summitedDates] ?? [];
            List<DateTime> summitedDates = [];
            for (var date in summitedDatesRaw) {
              if (date is Timestamp) {
                summitedDates.add((date).toDate());
              } else if (date is DateTime) {
                summitedDates.add(date);
              }
            }
            var summitDateRaw = correspondingDict[MunroFields.summitedDate];
            DateTime summitedDate = DateTime.now();
            if (summitDateRaw is Timestamp) {
              summitedDate = (summitDateRaw).toDate();
            } else if (summitDateRaw is DateTime) {
              summitedDate = summitDateRaw;
            }
            munro.summited = correspondingDict[MunroFields.summited];
            munro.summitedDates = summitedDates;
            munro.summitedDate = summitedDate;
            munro.saved = correspondingDict[MunroFields.saved];
          }
        }
      }
      munroState.setMunroList = munroList;

      // Set status
      munroState.setStatus = MunroStatus.loaded;

      // Load munro additional munro data
      loadAllAdditionalMunrosData(context);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      munroState.setError = Error(
        code: error.toString(),
        message: "There was an issue loading you munro data",
      );
    }
  }

  static loadPersonalMunroData(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: false);
    if (userState.currentUser == null) return;
  }

  static Future<void> loadAllAdditionalMunrosData(BuildContext context) async {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    // Read all munro review data
    List<Map<String, dynamic>> munroData = await MunroDatabase.getAllAdditionalMunrosData(context);
    List<Munro> tempMunroList = munroState.munroList;

    // Loop through all munros and add review data that exists
    for (var munro in munroData) {
      String munroId = munro[MunroFields.id];
      double averageRating = (munro[MunroFields.averageRating] as num).toDouble();
      int reviewCount = munro[MunroFields.reviewCount] as int;

      tempMunroList[int.parse(munroId) - 1].averageRating = averageRating;
      tempMunroList[int.parse(munroId) - 1].reviewCount = reviewCount;
    }

    munroState.setMunroList = tempMunroList;
  }

  static Future<void> loadAdditionalMunroData(BuildContext context) async {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    // Modify to be a single munro

    // Read single munro data
    Map<String, dynamic> munroData = await MunroDatabase.getAdditionalMunroData(
      context,
      munroId: munroState.selectedMunro?.id ?? "",
    );

    List<Munro> tempMunroList = munroState.munroList;

    String munroId = munroData[MunroFields.id];
    double averageRating = (munroData[MunroFields.averageRating] as num).toDouble();
    int reviewCount = munroData[MunroFields.reviewCount] as int;

    tempMunroList[int.parse(munroId) - 1].averageRating = averageRating;
    tempMunroList[int.parse(munroId) - 1].reviewCount = reviewCount;

    munroState.setMunroList = tempMunroList;
    munroState.setSelectedMunro = tempMunroList[int.parse(munroId) - 1];
  }

  static Future<void> markMunrosAsDone(
    BuildContext context, {
    required List<Munro> munros,
    required DateTime summitDateTime,
  }) async {
    // State management
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    if (userState.currentUser == null) return;
    // Update user data with new personal munro data
    AppUser newAppUser = userState.currentUser!;

    for (Munro munro in munros) {
      newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.summited] = true;
      List<dynamic> summitedDatesRaw =
          newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.summitedDates] ?? [];
      summitedDatesRaw.add(Timestamp.fromDate(summitDateTime));

      newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.summitedDates] = summitedDatesRaw;

      // Update munro notifier
      munroState.updateMunro(
        munroId: munro.id,
        summited: true,
        summitedDate: summitDateTime,
      );
    }

    UserService.updateUser(context, appUser: newAppUser);
  }

  static Future<void> bulkUpdateMunros(
    BuildContext context,
  ) async {
    // State management
    UserState userState = Provider.of<UserState>(context, listen: false);
    BulkMunroUpdateState bulkMunroUpdateState = Provider.of<BulkMunroUpdateState>(context, listen: false);

    if (userState.currentUser == null) return;
    // Update user data with new personal munro data
    AppUser newAppUser = userState.currentUser!.copyWith(personalMunroData: bulkMunroUpdateState.bulkMunroUpdateList);

    UserService.updateUser(context, appUser: newAppUser);
    loadMunroData(context);
  }

  static Future<void> removeMunroCompletion(
    BuildContext context, {
    required Munro munro,
    required DateTime dateTime,
  }) async {
// State management
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    if (userState.currentUser == null) return;
    // Update user data with new personal munro data
    AppUser newAppUser = userState.currentUser!;

    List<dynamic> summitedDatesRaw =
        newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.summitedDates] ?? [];
    summitedDatesRaw.remove(Timestamp.fromDate(dateTime));

    newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.summitedDates] = summitedDatesRaw;
    newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.summited] = summitedDatesRaw.isNotEmpty;

    // Update munro notifier
    munroState.removeMunroCompletion(
      munroId: munro.id,
      dateTime: dateTime,
    );

    userState.setCurrentUserWithNotify(newAppUser, notify: false);

    await AchievementService.checkAchievements(context);
    await UserService.updateUser(context, appUser: newAppUser);
  }

  static Future<void> toggleMunroSaved(
    BuildContext context, {
    required Munro munro,
  }) async {
    // State management
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    if (userState.currentUser == null) return;

    // Update user data with new personal munro data
    AppUser newAppUser = userState.currentUser!;
    newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.saved] =
        !newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.saved];

    UserService.updateUser(context, appUser: newAppUser);

    // Update munro notifier
    munroState.updateMunro(
      munroId: munro.id,
      saved: newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.saved],
    );
  }
}
