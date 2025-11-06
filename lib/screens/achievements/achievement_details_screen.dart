import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AchievementDetailsScreenArgs {
  final Achievement achievement;
  AchievementDetailsScreenArgs({required this.achievement});
}

class AchievementDetailScreen extends StatelessWidget {
  static const String route = '/achievement_detail';
  final AchievementDetailsScreenArgs args;
  const AchievementDetailScreen({super.key, required this.args});

  Widget _buildMessage(BuildContext context, Achievement achievement) {
    if (achievement.completed) {
      return Column(
        children: [
          const SizedBox(height: 20),
          const Text('🎉', style: TextStyle(fontSize: 60)),
          Text(
            'Congratulations!',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          Text(
            'You have completed this achievement.',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w300,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 20),
          const Text('🥾', style: TextStyle(fontSize: 60)),
          Text(
            'You still have a bit to go on this achievement.',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w300,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Achievement achievement = args.achievement;
    return Scaffold(
      appBar: AppBar(
        title: Text(achievement.name),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessage(context, achievement),
            const PaddedDivider(),
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            achievement.type == AchievementTypes.multiMunroDay
                ? const SizedBox()
                : Text("Progress: ${achievement.progress}/${achievement.criteriaCount}"),
          ],
        ),
      ),
    );
  }
}
