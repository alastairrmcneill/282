import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroChallengeListScreen extends StatelessWidget {
  static const String route = '/munro_challenges';
  const MunroChallengeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Munro Challenge'),
      ),
      body: Center(
        child: ListView.separated(
          itemCount: achievementsState.achievements
              .where((Achievement achievement) => achievement.type == AchievementTypes.annualGoal)
              .toList()
              .length,
          itemBuilder: (context, index) {
            List<Achievement> sortedAchievements = achievementsState.achievements
                .where((Achievement achievement) => achievement.type == AchievementTypes.annualGoal)
                .toList();

            sortedAchievements.sort((a, b) => b.uid.compareTo(a.uid));

            Achievement achievement = sortedAchievements[index];

            return ListTile(
              title: Text(achievement.name),
              subtitle: Text(achievement.description),
              trailing: achievement.completed ? const Icon(Icons.check) : null,
              onTap: achievement.criteria[CriteriaFields.year] == DateTime.now().year
                  ? () {
                      achievementsState.reset();
                      achievementsState.setCurrentAchievement = achievement;
                      Navigator.of(context).pushNamed(MunroChallengeDetailScreen.route);
                    }
                  : null,
            );
          },
          separatorBuilder: (context, index) => Divider(),
        ),
      ),
    );
  }
}
