import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';

class StravaMatchesReviewBottomSheetTitle extends StatelessWidget {
  final PendingActivityReview review;
  const StravaMatchesReviewBottomSheetTitle({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final matchCount = review.matches.length;
    final munroWord = matchCount == 1 ? 'Munro' : 'Munros';
    final dayName = DateFormat('EEEE').format(review.activity.startDate);

    return SizedBox(
      width: double.infinity,
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          style: Theme.of(context).textTheme.headlineMedium,
          children: [
            TextSpan(
                text: '$matchCount ',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: context.colors.accent)),
            TextSpan(
              text: '$munroWord on \n$dayName\'s ${review.activity.activityType.toLowerCase()}?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
