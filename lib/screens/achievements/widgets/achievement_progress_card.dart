import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/support/theme.dart';

class AchievementProgressCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementProgressCard({super.key, required this.achievement});

  String _progressLabel() {
    final progress = achievement.progress;
    final criteriaCount = achievement.criteriaCount ?? 0;
    final target = criteriaCount > 0 ? criteriaCount : 1;

    if (achievement.type == AchievementTypes.annualGoal) {
      return '$progress Munros logged this year';
    }
    if (achievement.type == AchievementTypes.monthlyMunro) {
      return '$progress / 12 months covered';
    }
    if (criteriaCount == 0) {
      return achievement.completed ? 'Completed' : 'Not yet started';
    }
    return '$progress / $target';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCompleted = achievement.completed;
    final criteriaCount = achievement.criteriaCount ?? 0;
    final target = criteriaCount > 0 ? criteriaCount : 1;
    final progressPct = (achievement.progress / target).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 0.65),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your progress',
                style: textTheme.bodyMedium?.copyWith(color: colors.textSubtitle),
              ),
              Flexible(
                child: Text(
                  _progressLabel(),
                  textAlign: TextAlign.end,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? colors.accent : colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          if (criteriaCount > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progressPct,
                minHeight: 10,
                backgroundColor: colors.border.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? colors.accent : colors.middleGrey,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0', style: textTheme.bodySmall?.copyWith(color: colors.middleGrey)),
                Text('$target', style: textTheme.bodySmall?.copyWith(color: colors.middleGrey)),
              ],
            ),
          ],
          if (criteriaCount == 0) ...[
            const SizedBox(height: 4),
            Text(
              isCompleted
                  ? 'Achievement earned — well done.'
                  : 'Keep climbing to unlock this badge.',
              style: textTheme.bodySmall?.copyWith(color: colors.middleGrey),
            ),
          ],
        ],
      ),
    );
  }
}
