import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class AchievementListScreen extends StatelessWidget {
  const AchievementListScreen({super.key});
  static const String route = '/achievements_list';

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: Center(
        child: ListView.separated(
          itemCount: achievementsState.achievements
              .where((Achievement achievement) => achievement.type != AchievementTypes.annualGoal)
              .length,
          itemBuilder: (context, index) {
            List<Achievement> sortedAchievements = achievementsState.achievements
                .where((Achievement achievement) => achievement.type != AchievementTypes.annualGoal)
                .toList();

            sortedAchievements.sort((a, b) => a.achievementId.compareTo(b.achievementId));

            Achievement achievement = sortedAchievements[index];

            return ListTile(
              title: Text(achievement.name),
              subtitle: Text(achievement.description),
              trailing: achievement.completed ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pushNamed(
                context,
                AchievementDetailScreen.route,
                arguments: AchievementDetailsScreenArgs(
                  achievement: achievement,
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
    );
  }
}
