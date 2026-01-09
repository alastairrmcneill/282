import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';

class ProfileMunroChallengeWidget extends StatelessWidget {
  final double width;
  final double height;
  const ProfileMunroChallengeWidget({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileState>();
    final achievementsState = context.watch<AchievementsState>();

    String annualGoalId = profileState.profile?.annualGoalId ?? '';
    int year = profileState.profile?.annualGoalYear ?? 2025;
    int count = profileState.profile?.annualGoalTarget ?? 0;
    int progress = profileState.profile?.annualGoalProgress ?? 0;

    bool isCurrentUser = profileState.isCurrentUser;

    String getCountText(bool isCurrentUser, int count) {
      if (isCurrentUser) {
        return count == 0 ? "Click to set a goal for the year!" : " / $count";
      } else {
        return count == 0 ? "No goal set" : " / $count";
      }
    }

    return ClickableStatBox(
      onTap: () {
        if (isCurrentUser) {
          achievementsState.reset();
          achievementsState.setCurrentAchievement =
              achievementsState.achievements.where((a) => a.achievementId == annualGoalId).first;
          Navigator.of(context).pushNamed(MunroChallengeDetailScreen.route);
        }
      },
      progress: count == 0 ? "" : progress.toString(),
      count: getCountText(isCurrentUser, count),
      subtitle: "$year Challenge",
    );
  }
}
