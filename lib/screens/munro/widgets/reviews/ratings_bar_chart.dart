import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';

class RatingsBarChart extends StatelessWidget {
  final MunroRatingsBreakdown ratingsBreakdown;
  const RatingsBarChart({super.key, required this.ratingsBreakdown});

  Widget buildRatingBar(BuildContext context, int rating, int count) {
    return Row(
      children: [
        Text(
          rating.toString(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
        ),
        const SizedBox(width: 2),
        Icon(Icons.star_rounded, color: context.colors.starColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: ratingsBreakdown.totalRatings > 0 ? count / ratingsBreakdown.totalRatings : 0,
            backgroundColor: context.colors.border,
            color: context.colors.starColor,
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
