import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroChallengeService {
  static Future setMunroChallenge(BuildContext context) async {
    MunroChallengeState munroChallengeState = Provider.of<MunroChallengeState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    if (userState.currentUser == null) return;

    try {
      munroChallengeState.setStatus = MunroChallengeStatus.loading;

      // Does a goal for this year exist alrady?
      int index = userState.currentUser!.munroChallenges
          .indexWhere((MunroChallenge challenge) => challenge.year == DateTime.now().year);

      if (index != -1) {
        // Update existing goal
        MunroChallenge newMunroChallenge = userState.currentUser!.munroChallenges[index].copyWith(
          target: munroChallengeState.munroChallengeCountForm,
        );
        munroChallengeState.setCurrentMunroChallenge = newMunroChallenge;
        userState.currentUser!.munroChallenges[index] = newMunroChallenge;
      } else {
        // Add new goal
        MunroChallenge newMunroChallenge = MunroChallenge(
          year: DateTime.now().year,
          target: munroChallengeState.munroChallengeCountForm,
          completedMunros: [],
        );
        munroChallengeState.setCurrentMunroChallenge = newMunroChallenge;
        userState.currentUser!.munroChallenges.add(newMunroChallenge);
      }

      await UserDatabase.update(context, appUser: userState.currentUser!);

      // Set status
      munroChallengeState.setStatus = MunroChallengeStatus.loaded;
    } catch (error) {
      munroChallengeState.setError = Error(
        code: error.toString(),
        message: "There was an issue setting you munro challenge.",
      );
    }
  }

  static bool checkMunroChallengeCompleted(MunroChallenge? munroChallenge) {
    if (munroChallenge == null) return false;
    return munroChallenge.completedMunros.length >= munroChallenge.target;
  }
}
