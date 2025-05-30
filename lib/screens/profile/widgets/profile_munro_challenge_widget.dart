import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/achievement_model.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';

class ProfileMunroChallengeWidget extends StatelessWidget {
  final double width;
  final double height;
  const ProfileMunroChallengeWidget({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    ProfileState profileState = Provider.of<ProfileState>(context);
    AchievementsState achievementsState = Provider.of<AchievementsState>(context);
    var munroChallenge = profileState.user?.achievements?["${AchievementTypes.annualGoal}${DateTime.now().year}"];

    if (munroChallenge == null) {
      return const SizedBox();
    }

    Achievement achievement = Achievement.fromJSON(munroChallenge);

    int year = achievement.criteria[CriteriaFields.year];
    int count = achievement.criteria[CriteriaFields.count];
    int progress = achievement.progress;

    return ClickableStatBox(
      onTap: () {
        if (profileState.isCurrentUser) {
          achievementsState.reset();
          achievementsState.setCurrentAchievement = achievement;
          Navigator.of(context).pushNamed(MunroChallengeDetailScreen.route);
        }
      },
      progress: count == 0 ? "" : progress.toString(),
      count: count == 0 ? "Click to set a goal for the year!" : " / $count",
      subtitle: "$year Challenge",
    );
  }
}
