import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/achievements/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';

class AchievementDetailsScreenArgs {
  final Achievement achievement;
  AchievementDetailsScreenArgs({required this.achievement});
}

class AchievementDetailScreen extends StatelessWidget {
  static const String route = '/achievement_detail';
  final AchievementDetailsScreenArgs args;
  const AchievementDetailScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final achievement = args.achievement;
    final colors = context.colors;
    final isCompleted = achievement.completed;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            AchievementBadgeIcon(
              achievement: achievement,
              containerSize: 128,
              iconSize: 64,
              containerRadius: 24,
            ),
            const SizedBox(height: 20),
            _StatusPill(isCompleted: isCompleted),
            const SizedBox(height: 16),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colors.textSubtitle),
            ),
            if (achievement.type != AchievementTypes.multiMunroDay) ...[
              const SizedBox(height: 32),
              AchievementProgressCard(achievement: achievement),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isCompleted;
  const _StatusPill({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted
            ? colors.accent.withValues(alpha: 0.12)
            : colors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isCompleted ? 'Unlocked' : 'Locked',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isCompleted ? colors.accent : colors.textMuted,
        ),
      ),
    );
  }
}
