import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroChallengeWidget extends StatelessWidget {
  const MunroChallengeWidget({super.key});

  Widget _buildText(Achievement achievement) {
    if (achievement.criteria[CriteriaFields.count] == 0) {
      return const Text("You haven't set a target for this year yet.");
    } else {
      return Text(
        "Your goal for ${achievement.criteria[CriteriaFields.year]} is ${achievement.criteria[CriteriaFields.count]} munro${achievement.criteria[CriteriaFields.count] == 1 ? "" : "s"}. So far you’ve climbed ${achievement.progress}.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context);

    Achievement achievement = achievementsState.achievements.firstWhere(
        (Achievement achievement) =>
            achievement.type == AchievementTypes.annualGoal &&
            achievement.criteria[CriteriaFields.year] == DateTime.now().year,
        orElse: () => Achievement(
              uid: "",
              name: "",
              description: "",
              type: AchievementTypes.totalCount,
              completed: false,
              criteria: {},
              progress: 0,
            ));

    if (achievement.criteria[CriteriaFields.year] != DateTime.now().year) return const SizedBox();
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
