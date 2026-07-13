import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'achievement_type_icon.dart';

class AchievementBadgeIcon extends StatelessWidget {
  final Achievement achievement;
  final double containerSize;
  final double iconSize;

  const AchievementBadgeIcon({
    super.key,
    required this.achievement,
    this.containerSize = 52,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompleted = achievement.completed;

    final badgeImage = Image.asset(
      'assets/badges/${achievement.achievementId}.png',
      width: containerSize,
      height: containerSize,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      // Falls back to the generic type icon if achievementId has no matching PNG in assets/badges/.
      errorBuilder: (context, error, stackTrace) => Icon(
        achievementTypeIcon(achievement.type),
        size: iconSize,
        color: isCompleted ? colors.accent : colors.middleGrey,
      ),
    );

    return isCompleted
        ? badgeImage
        : ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
            child: badgeImage,
          );
  }
}
