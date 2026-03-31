import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';

class AverageRatingWidget extends StatelessWidget {
  final MunroRatingsBreakdown ratingsBreakdown;
  const AverageRatingWidget({super.key, required this.ratingsBreakdown});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ratingsBreakdown.averageRating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        RatingBarIndicator(
          rating: ratingsBreakdown.averageRating,
          itemSize: 20,
          unratedColor: context.colors.border,
          itemBuilder: (context, index) {
            return Icon(Icons.star_rounded, color: context.colors.starColor);
          },
        ),
        const SizedBox(height: 4),
        Text(
          "${ratingsBreakdown.totalRatings} rating${ratingsBreakdown.totalRatings != 1 ? 's' : ''}",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
        ),
      ],
    );
  }
}
