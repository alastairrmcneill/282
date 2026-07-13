import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class ChallengeImpactStats extends StatelessWidget {
  final int goal;
  final int completedCount;

  const ChallengeImpactStats({
    super.key,
    required this.goal,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (goal - completedCount).clamp(0, 282);
    final monthsRemaining = (12 - DateTime.now().month).clamp(0, 12);
    final requiredPerMonth = monthsRemaining > 0
        ? (remaining / monthsRemaining).ceil()
        : remaining;
    final goalAchieved = completedCount >= goal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border, width: 0.65),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What This Means',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          _StatRow(
            icon: PhosphorIconsRegular.target,
            iconColor: const Color(0xFF3B82F6),
            iconBgColor: const Color(0xFF3B82F6),
            title: '$remaining munros to go',
            subtitle: goalAchieved ? 'Goal already achieved!' : 'Remaining this year',
          ),
          if (!goalAchieved) ...[
            const SizedBox(height: 12),
            _StatRow(
              icon: PhosphorIconsRegular.trendUp,
              iconColor: const Color(0xFFA855F7),
              iconBgColor: const Color(0xFFA855F7),
              title: '$requiredPerMonth per month',
              subtitle: 'Required pace to hit your goal',
            ),
          ],
          const SizedBox(height: 12),
          _StatRow(
            icon: PhosphorIconsRegular.calendar,
            iconColor: const Color(0xFFF97316),
            iconBgColor: const Color(0xFFF97316),
            title: '$monthsRemaining months left',
            subtitle: 'Until end of ${DateTime.now().year}',
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.colors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
