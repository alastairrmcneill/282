import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class ReviewService {
  static Future createReview(BuildContext context) async {
    // Create review
    CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      createReviewState.setStatus = CreateReviewStatus.loading;

      for (var key in createReviewState.reviews.keys) {
        Review review = Review(
          authorId: userState.currentUser?.uid ?? "",
          authorDisplayName: userState.currentUser?.displayName ?? "",
          authorProfilePictureURL: userState.currentUser?.profilePictureURL,
          dateTime: DateTime.now().toUtc(),
          rating: createReviewState.reviews[key]![ReviewFields.rating] ?? 0,
          text: createReviewState.reviews[key]!["review"] ?? "",
          munroId: key,
        );

        // Upload to database

        await ReviewDatabase.create(context, review: review);
        MunroService.loadMunroData(context);
      }

      createReviewState.setStatus = CreateReviewStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      createReviewState.setError = Error(
        message: "There was an issue posting your review. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future editReview(BuildContext context) async {
    CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);
    ReviewsState reviewsState = Provider.of<ReviewsState>(context, listen: false);

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
      MunroService.loadMunroData(context);

      reviewsState.replaceReview = newReview;
      createReviewState.setStatus = CreateReviewStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      createReviewState.setError = Error(
        message: "There was an issue editing your review. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future getMunroReviews(BuildContext context) async {
    ReviewsState reviewsState = Provider.of<ReviewsState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    List<String> blockedUsers = userState.currentUser?.blockedUsers ?? [];

    try {
      reviewsState.setStatus = ReviewsStatus.loading;
      List<Review> reviews = [];

      // Get reviews
      reviews = await ReviewDatabase.readReviewsFromMunro(
        context,
        munroId: munroState.selectedMunro?.id ?? 0,
        excludedAuthorIds: blockedUsers,
        offset: 0,
      );

      reviewsState.setReviews = reviews;
      reviewsState.setStatus = ReviewsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      reviewsState.setError = Error(
        message: "There was an issue getting reviews for this munro. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future paginateMunroReviews(BuildContext context) async {
    ReviewsState reviewsState = Provider.of<ReviewsState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      reviewsState.setStatus = ReviewsStatus.paginating;
      List<Review> reviews = [];
      List<String> blockedUsers = userState.currentUser?.blockedUsers ?? [];

      reviews = await ReviewDatabase.readReviewsFromMunro(
        context,
        munroId: munroState.selectedMunro?.id ?? 0,
        excludedAuthorIds: blockedUsers,
        offset: reviewsState.reviews.length,
      );

      reviewsState.addReviews = reviews;
      reviewsState.setStatus = ReviewsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      reviewsState.setError = Error(
        message: "There was an issue getting reviews for this munro. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future deleteReview(BuildContext context, {required Review review}) async {
    CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);
    ReviewsState reviewsState = Provider.of<ReviewsState>(context, listen: false);

    try {
      createReviewState.setStatus = CreateReviewStatus.loading;

      await ReviewDatabase.delete(context, uid: review.uid!);
      MunroService.loadMunroData(context);

      reviewsState.removeReview(review);
      createReviewState.setStatus = CreateReviewStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      createReviewState.setError = Error(
        message: "There was an issue deleting your review. Please try again",
        code: error.toString(),
      );
    }
  }
}
