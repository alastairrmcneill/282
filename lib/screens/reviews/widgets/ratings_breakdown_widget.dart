import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/reviews/widgets/widgets.dart';

class RatingsBreakdownWidget extends StatelessWidget {
  final MunroRatingsBreakdown ratingsBreakdown;
  const RatingsBreakdownWidget({super.key, required this.ratingsBreakdown});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AverageRatingWidget(ratingsBreakdown: ratingsBreakdown),
        const SizedBox(width: 20),
        Expanded(child: RatingsBarChart(ratingsBreakdown: ratingsBreakdown)),
      ],
    );
  }
}
