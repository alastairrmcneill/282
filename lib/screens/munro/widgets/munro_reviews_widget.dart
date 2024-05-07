import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/reviews/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class MunroReviewsWidget extends StatelessWidget {
  const MunroReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ReviewsState reviewsState = Provider.of<ReviewsState>(context);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    return Column(
      children: [
        InkWell(
          onTap: () {
            ReviewService.getMunroReviews(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReviewsScreen()),
            );
          },
          child: Container(
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "Reviews",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Icon(
                  CupertinoIcons.right_chevron,
                  size: 16,
                )
              ],
            ),
          ),
        ),
        reviewsState.reviews.isEmpty
            ? const Center(
                child: Text("No reviews available"),
              )
            : SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          munroState.selectedMunro?.averageRating?.toStringAsFixed(1) ?? "0",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 20),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          CupertinoIcons.star_fill,
                          size: 20,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '/ ${munroState.selectedMunro?.reviewCount == 1 ? "1 rating" : "${munroState.selectedMunro?.reviewCount} ratings"}',
                          style: TextStyle(fontWeight: FontWeight.w200, color: Colors.grey[800]),
                        )
                      ],
                    ),
                    ...reviewsState.reviews.take(4).map(
                      (Review review) {
                        return ReviewListTile(review: review);
                      },
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
