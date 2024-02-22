import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/reviews/widgets/widgets.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReviewsListWidget extends StatelessWidget {
  const ReviewsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsState>(
      builder: (context, reviewsState, child) {
        switch (reviewsState.status) {
          case ReviewsStatus.loading:
            return _buildLoadingScreen(context, reviewsState);

          case ReviewsStatus.error:
            print('reviewsState.error.message: ${reviewsState.error.code}  ');
            return SizedBox(
              width: double.infinity,
              height: 300,
              child: CenterText(text: reviewsState.error.message),
            );
          default:
            return _buildScreen(context, reviewsState);
        }
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context, ReviewsState reviewsState) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return const ShimmerListTile();
      },
    );
  }

  Widget _buildScreen(BuildContext context, ReviewsState reviewsState) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: min(reviewsState.reviews.length, 10),
      itemBuilder: (context, index) {
        Review review = reviewsState.reviews[index];
        return ReviewListTile(review: review);
      },
    );
  }
}
