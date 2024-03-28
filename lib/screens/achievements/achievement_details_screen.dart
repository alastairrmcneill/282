import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class AchievementDetailScreen extends StatelessWidget {
  final Achievement achievement;
  const AchievementDetailScreen({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(achievement.name),
      ),
      body: Center(
        child: Column(
          children: [
            Text(achievement.description),
            Text(achievement.completed ? "Completed" : "Not completed"),
            achievement.type == AchievementTypes.multiMunroDay
                ? const SizedBox()
                : Text("Progress: ${achievement.progress}"),
          ],
        ),
      ),
    );
  }
}
