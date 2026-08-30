import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class StravaMatchesSummaryStatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool accent;
  const StravaMatchesSummaryStatCard({
    super.key,
    required this.value,
    required this.label,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ? context.colors.accent : context.colors.textPrimary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent ? context.colors.accent.withValues(alpha: 0.08) : context.colors.divider,
        borderRadius: BorderRadius.circular(14),
        border: accent ? Border.all(color: context.colors.accent.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
          ),
        ],
      ),
    );
  }
}
