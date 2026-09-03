import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/strava/strava_connected_colors.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaConnectedStepTile extends StatelessWidget {
  final int number;
  final String text;

  const StravaConnectedStepTile({
    super.key,
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.accent.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                '$number',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: StravaConnectedColors.accentText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: StravaConnectedColors.textSubtitle),
            ),
          ),
        ],
      ),
    );
  }
}
