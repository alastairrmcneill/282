import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class FoundOnStravaSubtitle extends StatelessWidget {
  final List<PendingActivityReview> reviews;

  const FoundOnStravaSubtitle({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final activityCount = reviews.length;
    final matchCount = reviews.fold<int>(0, (sum, r) => sum + r.matches.length);

    return Text(
      '$activityCount activities $matchCount Munros. Take a look one at a time - nothing saves until you say so.',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w300),
    );
  }
}
