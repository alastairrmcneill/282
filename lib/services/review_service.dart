import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/munro_service.dart';
import 'package:two_eight_two/services/services.dart';

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

      MunroService.loadAdditionalMunroData(context);
      createReviewState.setStatus = CreateReviewStatus.loaded;
    } catch (error, stackTrace) {
      Log.error("Error: $error", stackTrace: stackTrace);
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

      reviewsState.replaceReview = newReview;
      MunroService.loadAdditionalMunroData(context);
      createReviewState.setStatus = CreateReviewStatus.loaded;
    } catch (error, stackTrace) {
      Log.error("Error: $error", stackTrace: stackTrace);
      createReviewState.setError = Error(
        message: "There was an issue editing your review. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future getProfileReviews(BuildContext context) async {
    ReviewsState reviewsState = Provider.of<ReviewsState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    try {
      reviewsState.setStatus = ReviewsStatus.loading;

      // Get reviews
      List<Review> reviews = await ReviewDatabase.readReviewsFromUser(
        context,
        authorId: profileState.user?.uid ?? "",
        lastReviewId: null,
      );

      reviewsState.setReviews = reviews;
      reviewsState.setStatus = ReviewsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error("Error: $error", stackTrace: stackTrace);
      reviewsState.setError = Error(
        message: "There was an issue getting your reviews. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future paginateProfileReviews(BuildContext context) async {
    ReviewsState reviewsState = Provider.of<ReviewsState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);

    try {
      reviewsState.setStatus = ReviewsStatus.paginating;

      // Get reviews
      List<Review> reviews = await ReviewDatabase.readReviewsFromUser(
        context,
        authorId: profileState.user?.uid ?? "",
        lastReviewId: reviewsState.reviews.last.uid,
      );

      reviewsState.addReviews = reviews;
      reviewsState.setStatus = ReviewsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error("Error: $error", stackTrace: stackTrace);
      reviewsState.setError = Error(
        message: "There was an issue getting your reviews. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future getMunroReviews(BuildContext context) async {
    ReviewsState reviewsState = Provider.of<ReviewsState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    try {
      reviewsState.setStatus = ReviewsStatus.loading;

      // Get reviews
      List<Review> reviews = await ReviewDatabase.readReviewsFromMunro(
        context,
        munroId: munroState.selectedMunro?.id ?? "",
        lastReviewId: null,
      );

      reviewsState.setReviews = reviews;
      reviewsState.setStatus = ReviewsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error("Error: $error", stackTrace: stackTrace);
      reviewsState.setError = Error(
        message: "There was an issue getting reviews for this munro. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future paginateMunroReviews(BuildContext context) async {
    ReviewsState reviewsState = Provider.of<ReviewsState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    try {
      reviewsState.setStatus = ReviewsStatus.paginating;

      // Get reviews
      List<Review> reviews = await ReviewDatabase.readReviewsFromMunro(
        context,
        munroId: munroState.selectedMunro?.id ?? "",
        lastReviewId: reviewsState.reviews.last.uid,
      );

      reviewsState.addReviews = reviews;
      reviewsState.setStatus = ReviewsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error("Error: $error", stackTrace: stackTrace);
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

      // Send to database
      await ReviewDatabase.delete(context, uid: review.uid!);

      reviewsState.removeReview(review);
      createReviewState.setStatus = CreateReviewStatus.loaded;
    } catch (error, stackTrace) {
      Log.error("Error: $error", stackTrace: stackTrace);
      createReviewState.setError = Error(
        message: "There was an issue deleting your review. Please try again",
        code: error.toString(),
      );
    }
  }
}
