import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/repos/repos.dart';

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
            munro.summited = correspondingDict[MunroFields.summited];
            munro.summitedDate = (correspondingDict[MunroFields.summitedDate] as Timestamp?)?.toDate();
            munro.saved = correspondingDict[MunroFields.saved];
          }
        }
      }
      munroState.setMunroList = munroList;

      // Set status
      munroState.setStatus = MunroStatus.loaded;

      // Load munro additional munro data
      loadAdditionalMunroData(context);
    } catch (error, stackTrace) {
      Log.error("Error: $error", stackTrace: stackTrace);
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

  static Future<void> loadAdditionalMunroData(BuildContext context) async {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    // Read all munro review data
    List<Map<String, dynamic>> munroData = await MunroDatabase.getAdditionalMunroData(context);
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

  static Future<void> markMunrosAsDone(
    BuildContext context, {
    required List<Munro> munros,
  }) async {
    // State management
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    if (userState.currentUser == null) return;
    // Update user data with new personal munro data
    AppUser newAppUser = userState.currentUser!;

    for (Munro munro in munros) {
      newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.summited] = true;
      newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.summitedDate] = DateTime.now().toUtc();
      // Update munro notifier
      munroState.updateMunro(
        munroId: munro.id,
        summited: true,
        summitedDate: DateTime.now().toUtc(),
      );
    }

    UserDatabase.update(context, appUser: newAppUser);
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

    UserDatabase.update(context, appUser: newAppUser);

    // Update munro notifier
    munroState.updateMunro(
      munroId: munro.id,
      saved: newAppUser.personalMunroData![int.parse(munro.id) - 1][MunroFields.saved],
    );
  }
}
