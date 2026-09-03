import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';

class StravaMatchesSummaryBottomSheetTitle extends StatelessWidget {
  final List<PendingActivityReview> reviews;
  const StravaMatchesSummaryBottomSheetTitle({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final activityCount = reviews.length;
    final matchCount = reviews.fold<int>(0, (sum, r) => sum + r.matches.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You\'ve been busy!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 8),
        Text(
          '$activityCount activities look like they went over Munros — $matchCount in total. Have a quick look and we\'ll get them on your map.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.colors.textSubtitle),
        ),
      ],
    );
  }
}
