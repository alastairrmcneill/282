import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'achievement_type_icon.dart';

class AchievementBadgeIcon extends StatelessWidget {
  final Achievement achievement;
  final double containerSize;
  final double iconSize;
  final double containerRadius;

  const AchievementBadgeIcon({
    super.key,
    required this.achievement,
    this.containerSize = 48,
    this.iconSize = 24,
    this.containerRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompleted = achievement.completed;
    final lockBadgeSize = containerSize >= 100 ? 24.0 : 16.0;
    final lockIconSize = containerSize >= 100 ? 12.0 : 9.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: isCompleted
                ? colors.accent.withValues(alpha: 0.15)
                : colors.border.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(containerRadius),
          ),
          child: Icon(
            achievementTypeIcon(achievement.type),
            size: iconSize,
            color: isCompleted ? colors.accent : colors.middleGrey,
          ),
        ),
        if (!isCompleted)
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: lockBadgeSize,
              height: lockBadgeSize,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border, width: 0.65),
              ),
              child: Icon(
                Icons.lock_rounded,
                size: lockIconSize,
                color: colors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}
