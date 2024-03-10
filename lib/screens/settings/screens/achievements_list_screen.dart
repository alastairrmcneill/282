import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class AchievementListScreen extends StatelessWidget {
  const AchievementListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: Center(
        child: ListView(
          children: [
            ...achievementsState.achievements.map(
              (Achievement achievement) => ListTile(
                title: Text(achievement.name),
                subtitle: Text(achievement.description),
                trailing: achievement.completed ? const Icon(Icons.check) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
