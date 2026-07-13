import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'achievement_badge_icon.dart';

class AchievementBadgeTile extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onTap;

  const AchievementBadgeTile({
    super.key,
    required this.achievement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompleted = achievement.completed;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isCompleted
                ? AchievementBadgeIcon(achievement: achievement, containerSize: 64)
                : Image.asset('assets/badges/lock.png', width: 64, height: 64, fit: BoxFit.contain),
            const SizedBox(height: 6),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: isCompleted ? colors.accent : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
