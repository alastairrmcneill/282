import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/support/theme.dart';

class AchievementCompletedWidget extends StatelessWidget {
  final Achievement achievement;
  const AchievementCompletedWidget({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: MyColors.accentColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: MyColors.accentColor.withOpacity(0.2)),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(achievement.name, style: Theme.of(context).textTheme.labelLarge),
              SizedBox(height: 2),
              Text(achievement.description, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
