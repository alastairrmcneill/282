import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/models/models.dart';

class AchievementService {
  // Get User Achievements
  Future getUserAchievements(BuildContext context) async {
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
  Future getProfileAchievements(BuildContext context) async {
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
}
