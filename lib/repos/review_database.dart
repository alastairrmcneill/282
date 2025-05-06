import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReviewDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _reviewsRef = _db.collection('reviews');

  // Create Review
  static Future<void> create(BuildContext context, {required Review review}) async {
    try {
      DocumentReference ref = _reviewsRef.doc();

      Review newReview = review.copyWith(uid: ref.id);

      final data = newReview.toJSON()..[ReviewFields.dateTime] = FieldValue.serverTimestamp();

      await ref.set(data);
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error creating your review.");
    }
  }

  // Update Review
  static Future<void> update(BuildContext context, {required Review review}) async {
    try {
      DocumentReference ref = _reviewsRef.doc(review.uid);

      await ref.update(review.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error updating your review.");
    }
  }

  // Read review from uid
  static Future<Review?> readReviewFromUid(BuildContext context, {required String uid}) async {
    try {
      DocumentReference ref = _reviewsRef.doc(uid);
      DocumentSnapshot documentSnapshot = await ref.get();

      AnalyticsService.logDatabaseRead(
        method: "ReviewDatabase.readReviewFromUid",
        collection: "reviews",
        documentCount: 1,
        userId: null,
        documentId: uid,
      );

      Map<String, Object?> data = documentSnapshot.data() as Map<String, Object?>;

      Review review = Review.fromJSON(data);

      return review;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error fetching your review.");
      return null;
    }
  }

  // Read reviews from munro
  static Future<List<Review>> readReviewsFromMunro(
    BuildContext context, {
    required String munroId,
    required String? lastReviewId,
  }) async {
    List<Review> reviews = [];
    QuerySnapshot querySnapshot;

    try {
      if (lastReviewId == null) {
        // Load first batch
        querySnapshot = await _reviewsRef
            .orderBy(ReviewFields.dateTime, descending: true)
            .where(ReviewFields.munroId, isEqualTo: munroId)
            .limit(10)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "ReviewDatabase.readReviewsFromMunro.firstBatch",
          collection: "reviews",
          documentCount: querySnapshot.docs.length,
          userId: null,
          documentId: munroId,
        );
      } else {
        final lastPostDoc = await _reviewsRef.doc(lastReviewId).get();

        if (!lastPostDoc.exists) return [];

        querySnapshot = await _reviewsRef
            .orderBy(ReviewFields.dateTime, descending: true)
            .startAfterDocument(lastPostDoc)
            .where(ReviewFields.munroId, isEqualTo: munroId)
            .limit(10)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "ReviewDatabase.readReviewsFromMunro.paginate",
          collection: "reviews",
          documentCount: querySnapshot.docs.length,
          userId: null,
          documentId: munroId,
        );
      }

      for (var doc in querySnapshot.docs) {
        Map<String, Object?> data = doc.data() as Map<String, dynamic>;
        Review review = Review.fromJSON(data);
        reviews.add(review);
      }
      return reviews;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error fetching your reviews.");
      return reviews;
    }
  }

  // Read Reviews from User
  static Future<List<Review>> readReviewsFromUser(
    BuildContext context, {
    required String authorId,
    required String? lastReviewId,
  }) async {
    List<Review> reviews = [];
    QuerySnapshot querySnapshot;

    try {
      if (lastReviewId == null) {
        // Load first batch
        querySnapshot = await _reviewsRef
            .orderBy(ReviewFields.dateTime, descending: true)
            .where(ReviewFields.authorId, isEqualTo: authorId)
            .limit(10)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "ReviewDatabase.readReviewsFromUser.firstBatch",
          collection: "reviews",
          documentCount: querySnapshot.docs.length,
          userId: authorId,
          documentId: null,
        );
      } else {
        final lastPostDoc = await _reviewsRef.doc(lastReviewId).get();

        if (!lastPostDoc.exists) return [];

        querySnapshot = await _reviewsRef
            .orderBy(ReviewFields.dateTime, descending: true)
            .startAfterDocument(lastPostDoc)
            .where(ReviewFields.authorId, isEqualTo: authorId)
            .limit(10)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "ReviewDatabase.readReviewsFromUser.paginate",
          collection: "reviews",
          documentCount: querySnapshot.docs.length,
          userId: authorId,
          documentId: null,
        );
      }

      for (var doc in querySnapshot.docs) {
        Map<String, Object?> data = doc.data() as Map<String, dynamic>;
        Review review = Review.fromJSON(data);
        reviews.add(review);
      }
      return reviews;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error fetching your reviews.");
      return reviews;
    }
  }

  // Delete Review
  static Future<void> delete(BuildContext context, {required String uid}) async {
    try {
      DocumentReference ref = _reviewsRef.doc(uid);

      await ref.delete();
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error deleting your review.");
    }
  }
}
