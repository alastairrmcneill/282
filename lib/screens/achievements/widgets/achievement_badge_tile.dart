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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? colors.accent.withValues(alpha: 0.08)
              : colors.divider.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? colors.accent.withValues(alpha: 0.2)
                : colors.border,
            width: 0.65,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AchievementBadgeIcon(achievement: achievement),
            const SizedBox(height: 8),
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
