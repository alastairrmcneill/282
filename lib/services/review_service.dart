import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class ReviewService {
  static Future createReview(BuildContext context) async {
    // Create review
    CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      createReviewState.setStatus = CreateReviewStatus.loading;

      Review review = Review(
        authorId: userState.currentUser?.uid ?? "",
        authorDisplayName: userState.currentUser?.displayName ?? "",
        authorProfilePictureURL: userState.currentUser?.profilePictureURL,
        dateTime: DateTime.now().toUtc(),
        rating: createReviewState.currentMunroRating,
        text: createReviewState.currentMunroReview,
        munroId: createReviewState.munrosToReview[createReviewState.currentIndex].id,
      );

      // Upload to database
      await ReviewDatabase.create(context, review: review);

      // Reset state
      createReviewState.setCurrentMunroRating = 0;
      createReviewState.setCurrentMunroReview = "";

      createReviewState.setStatus = CreateReviewStatus.loaded;
    } catch (error) {
      createReviewState.setError = Error(message: "There was an issue posting your review. Please try again");
    }
  }

  static Future editReview(BuildContext context) async {
    CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);

    try {
      createReviewState.setStatus = CreateReviewStatus.loading;

      // Create new review
      Review review = createReviewState.editingReview!;

      Review newReview = review.copyWith(
        rating: createReviewState.currentMunroRating,
        text: createReviewState.currentMunroReview,
      );

      // Send to database
      await ReviewDatabase.update(context, review: newReview);

      createReviewState.setStatus = CreateReviewStatus.loaded;
    } catch (error) {
      createReviewState.setError = Error(message: "There was an issue editing your review. Please try again");
    }
  }

  static Future deleteReview(BuildContext context, {required Review review}) async {
    CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);

    try {
      createReviewState.setStatus = CreateReviewStatus.loading;

      // Send to database
      await ReviewDatabase.delete(context, uid: review.uid!);

      createReviewState.setStatus = CreateReviewStatus.loaded;
    } catch (error) {
      createReviewState.setError = Error(message: "There was an issue deleting your review. Please try again");
    }
  }
}
