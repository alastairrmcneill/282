import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReviewDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _reviewsRef = _db.from('reviews');
  static final SupabaseQueryBuilder _reviewsViewRef = _db.from('vu_munro_reviews');

  // Create Review
  static Future<void> create(BuildContext context, {required Review review}) async {
    try {
      await _reviewsRef.insert(review.toJSON());
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error creating your review.");
    }
  }

  // Update Review
  static Future<void> update(BuildContext context, {required Review review}) async {
    try {
      await _reviewsRef.update(review.toJSON()).eq(ReviewFields.uid, review.uid ?? "").select().single();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error updating your review.");
    }
  }

  // Read reviews from munro
  static Future<List<Review>> readReviewsFromMunro(
    BuildContext context, {
    required int munroId,
    required List<String> excludedAuthorIds,
    int offset = 0,
  }) async {
    List<Review> reviews = [];
    List<Map<String, dynamic>> response = [];
    int pageSize = 10;

    try {
      response = await _reviewsViewRef
          .select()
          .not(ReviewFields.authorId, 'in', excludedAuthorIds)
          .eq(ReviewFields.munroId, munroId)
          .order(ReviewFields.dateTime, ascending: false)
          .range(offset, offset + pageSize - 1);

      for (var doc in response) {
        Review review = Review.fromJSON(doc);
        reviews.add(review);
      }
      return reviews;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error fetching your reviews.");
      return reviews;
    }
  }

  // Delete Review
  static Future<void> delete(BuildContext context, {required String uid}) async {
    try {
      await _reviewsRef.delete().eq(ReviewFields.uid, uid);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error deleting your review.");
    }
  }
}
