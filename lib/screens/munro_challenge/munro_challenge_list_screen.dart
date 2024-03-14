import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroChallengeListScreen extends StatelessWidget {
  const MunroChallengeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Munro Challenge'),
      ),
      body: Center(
        child: ListView(
          children: [
            ...achievementsState.achievements
                .where((Achievement achievement) => achievement.type == AchievementTypes.annualGoal)
                .map(
                  (Achievement achievement) => ListTile(
                    title: Text(achievement.name),
                    subtitle: Text(achievement.description),
                    trailing: achievement.completed ? const Icon(Icons.check) : null,
                    onTap: () {
                      achievementsState.reset();
                      achievementsState.setCurrentAchievement = achievement;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateMunroChallengeScreen(),
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
