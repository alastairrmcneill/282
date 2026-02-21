import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/support/theme.dart';

class RatingsBarChart extends StatelessWidget {
  final MunroRatingsBreakdown ratingsBreakdown;
  const RatingsBarChart({super.key, required this.ratingsBreakdown});

  Widget buildRatingBar(BuildContext context, int rating, int count) {
    return Row(
      children: [
        Text(
          rating.toString(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MyColors.mutedText),
        ),
        const SizedBox(width: 2),
        Icon(Icons.star_rounded, color: MyColors.starColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: ratingsBreakdown.totalRatings > 0 ? count / ratingsBreakdown.totalRatings : 0,
            backgroundColor: MyColors.lightGrey,
            color: MyColors.starColor,
            minHeight: 3,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildRatingBar(context, 5, ratingsBreakdown.rating5Count),
        buildRatingBar(context, 4, ratingsBreakdown.rating4Count),
        buildRatingBar(context, 3, ratingsBreakdown.rating3Count),
        buildRatingBar(context, 2, ratingsBreakdown.rating2Count),
        buildRatingBar(context, 1, ratingsBreakdown.rating1Count),
      ],
    );
  }
}
