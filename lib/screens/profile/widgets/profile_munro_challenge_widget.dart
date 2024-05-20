import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        criteria: {"count": 0, "year": DateTime.now().year} as Map<String, dynamic>,
        progress: 0,
      ),
    );

    int year = achievement.criteria[CriteriaFields.year];
    int count = achievement.criteria[CriteriaFields.count];
    int progress = achievement.progress;

    return ClickableStatBox(
      onTap: () {
        if (profileState.isCurrentUser) {
          achievementsState.reset();
          achievementsState.setCurrentAchievement = achievement;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MunroChallengeListScreen(),
            ),
          );
        }
      },
      count: count.toString(),
      progress: progress.toString(),
      subtitle: "$year Challenge",
    );
  }
}
