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

      munroList = await MunroDatabase.getMunroData(context);

      if (userState.currentUser != null) {
        //TODO: mark if it is saved
      }
      munroState.setMunroList = munroList;

      // Set status
      munroState.setStatus = MunroStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      munroState.setError = Error(
        code: error.toString(),
        message: "There was an issue loading you munro data",
      );
    }
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

    int munroIndex =
        newAppUser.personalMunroData!.indexWhere((element) => element[MunroFields.id].toString() == munro.id);

    if (munroIndex == -1) return;
    newAppUser.personalMunroData![munroIndex][MunroFields.saved] =
        !newAppUser.personalMunroData![munroIndex][MunroFields.saved];

    UserService.updateUser(context, appUser: newAppUser);

    // TODO fix

    // // Update munro notifier
    // munroState.updateMunro(
    //   munroId: munro.id,
    //   saved: newAppUser.personalMunroData![munroIndex][MunroFields.saved],
    // );
  }
}
