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
        if (RemoteConfigService.getBool(RCFields.useSupabase)) {
          await ReviewDatabaseSupabase.create(context, review: review);
          MunroService.loadMunroData(context);
        } else {
          await ReviewDatabase.create(context, review: review);
          MunroService.loadAllAdditionalMunrosData(context);
        }
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
      if (RemoteConfigService.getBool(RCFields.useSupabase)) {
        await ReviewDatabaseSupabase.update(context, review: newReview);
        MunroService.loadMunroData(context);
      } else {
        await ReviewDatabase.update(context, review: newReview);
        MunroService.loadAllAdditionalMunrosData(context);
      }

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
      if (RemoteConfigService.getBool(RCFields.useSupabase)) {
        reviews = await ReviewDatabaseSupabase.readReviewsFromMunro(
          context,
          munroId: munroState.selectedMunro?.id ?? "",
          excludedAuthorIds: blockedUsers,
          offset: 0,
        );
      } else {
        reviews = await ReviewDatabase.readReviewsFromMunro(
          context,
          munroId: munroState.selectedMunro?.id ?? "",
          lastReviewId: null,
        );
        // Filter reviews
        reviews = reviews.where((review) => !blockedUsers.contains(review.authorId)).toList();
      }

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

      if (RemoteConfigService.getBool(RCFields.useSupabase)) {
        reviews = await ReviewDatabaseSupabase.readReviewsFromMunro(
          context,
          munroId: munroState.selectedMunro?.id ?? "",
          excludedAuthorIds: blockedUsers,
          offset: reviewsState.reviews.length,
        );
      } else {
        reviews = await ReviewDatabase.readReviewsFromMunro(
          context,
          munroId: munroState.selectedMunro?.id ?? "",
          lastReviewId: reviewsState.reviews.last.uid,
        );
        // Filter reviews
        reviews = reviews.where((review) => !blockedUsers.contains(review.authorId)).toList();
      }

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

      // Send to database
      if (RemoteConfigService.getBool(RCFields.useSupabase)) {
        await ReviewDatabaseSupabase.delete(context, uid: review.uid!);
        MunroService.loadMunroData(context);
      } else {
        await ReviewDatabase.delete(context, uid: review.uid!);
        MunroService.loadAllAdditionalMunrosData(context);
      }

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
