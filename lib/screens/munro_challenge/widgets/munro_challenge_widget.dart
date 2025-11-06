import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroChallengeWidget extends StatelessWidget {
  const MunroChallengeWidget({super.key});

  Widget _buildText(Achievement achievement) {
    if (achievement.annualTarget == 0) {
      return const Text("You haven't set a target for this year yet.");
    } else {
      return Text(
        "Your goal for ${achievement.criteriaValue} is ${achievement.annualTarget} munro${achievement.annualTarget == 1 ? "" : "s"}. So far you’ve climbed ${achievement.progress}.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context);

    Achievement achievement = achievementsState.achievements.firstWhere(
        (Achievement achievement) =>
            achievement.type == AchievementTypes.annualGoal &&
            int.parse(achievement.criteriaValue ?? "0") == DateTime.now().year,
        orElse: () => Achievement(
              name: "",
              description: "",
              type: AchievementTypes.totalCount,
              completed: false,
              progress: 0,
              annualTarget: 0,
              criteriaValue: DateTime.now().year.toString(),
              achievementId: "",
              userId: "",
              dateTimeCreated: DateTime.now(),
            ));

    if (int.parse(achievement.criteriaValue ?? "0") != DateTime.now().year) return const SizedBox();
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.blue[50],
      child: Column(
        children: [
          _buildText(achievement),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  achievementsState.reset();
                  achievementsState.setCurrentAchievement = achievement;
                  Navigator.of(context).pushNamed(CreateMunroChallengeScreen.route);
                },
                child: const Text("Edit"),
              ),
              TextButton(
                onPressed: () {
                  achievementsState.reset();
                  achievementsState.setCurrentAchievement = achievement;
                  Navigator.of(context).pushNamed(MunroChallengeListScreen.route);
                },
                child: const Text("Past Challenges"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
