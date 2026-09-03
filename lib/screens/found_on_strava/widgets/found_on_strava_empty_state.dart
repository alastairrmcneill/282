import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class FoundOnStravaEmptyState extends StatelessWidget {
  const FoundOnStravaEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.colors.border,
              shape: BoxShape.circle,
            ),
            width: 60,
            height: 60,
            child: Icon(
              PhosphorIconsRegular.checkCircle,
              size: 30,
              color: context.colors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Text('All caught up!', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(
            'You\'ve reviewed all your recent Strava activities. Check back after your next hike.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
