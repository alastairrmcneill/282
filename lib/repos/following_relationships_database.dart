// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FollowingRelationshipsDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _followingRelationshipRef = _db.collection('followingRelationships');

  static Future<QuerySnapshot> getRelationshipFromSourceAndTarget(
    BuildContext context, {
    required String sourceId,
    required String targetId,
  }) async {
    QuerySnapshot<Object?> querySnapshot = await _followingRelationshipRef
        .where(FollowingRelationshipFields.sourceId, isEqualTo: sourceId)
        .where(FollowingRelationshipFields.targetId, isEqualTo: targetId)
        .limit(1) // We only need to check if at least one document exists
        .get();

    AnalyticsService.logDatabaseRead(
      method: "FollowingRelationshipsDatabase.getRelationshipFromSourceAndTarget",
      collection: "followingRelationships",
      documentCount: querySnapshot.docs.length,
      userId: null,
      documentId: null,
    );

    return querySnapshot;
  }

  static Future create(
    BuildContext context, {
    required FollowingRelationship followingRelationship,
  }) async {
    try {
      DocumentReference ref = _followingRelationshipRef.doc();

      FollowingRelationship newFollowingRelationship = followingRelationship.copyWith(uid: ref.id);

      await ref.set(newFollowingRelationship.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error creating the relationship.");
    }
  }

  static Future delete(BuildContext context, {required String sourceId, required String targetId}) async {
    try {
      QuerySnapshot<Object?> querySnapshot = await _followingRelationshipRef
          .where(FollowingRelationshipFields.sourceId, isEqualTo: sourceId)
          .where(FollowingRelationshipFields.targetId, isEqualTo: targetId)
          .limit(1) // We only need to check if at least one document exists
          .get();

      AnalyticsService.logDatabaseRead(
        method: "FollowingRelationshipsDatabase.delete",
        collection: "followingRelationships",
        documentCount: querySnapshot.docs.length,
        userId: null,
        documentId: null,
      );
      await querySnapshot.docs[0].reference.delete();
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error deleting the relationship.");
    }
  }

  static Future<List<FollowingRelationship>> getFollowersFromUid(
    BuildContext context, {
    required String targetId,
    required String? lastFollowingRelationshipID,
  }) async {
    List<FollowingRelationship> followers = [];
    QuerySnapshot<Object?> querySnapshot;

    try {
      if (lastFollowingRelationshipID == null) {
        // First loading
        querySnapshot = await _followingRelationshipRef
            .where(FollowingRelationshipFields.targetId, isEqualTo: targetId)
            .orderBy(FollowingRelationshipFields.sourceDisplayName, descending: false)
            .limit(20) // We only need to check if at least one document exists
            .get();

        AnalyticsService.logDatabaseRead(
          method: "FollowingRelationshipsDatabase.getFollowersFromUid.firstLoad",
          collection: "followingRelationships",
          documentCount: querySnapshot.docs.length,
          userId: targetId,
          documentId: null,
        );
      } else {
        // Paginating
        final lastFollowingRelationshipDoc = await _followingRelationshipRef.doc(lastFollowingRelationshipID).get();

        if (!lastFollowingRelationshipDoc.exists) return [];

        querySnapshot = await _followingRelationshipRef
            .where(FollowingRelationshipFields.targetId, isEqualTo: targetId)
            .orderBy(FollowingRelationshipFields.sourceDisplayName, descending: false)
            .startAfterDocument(lastFollowingRelationshipDoc)
            .limit(20)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "FollowingRelationshipsDatabase.getFollowersFromUid.paginate",
          collection: "followingRelationships",
          documentCount: querySnapshot.docs.length,
          userId: targetId,
          documentId: null,
        );
      }

      for (var doc in querySnapshot.docs) {
        FollowingRelationship followingRelationship =
            FollowingRelationship.fromJSON(doc.data() as Map<String, dynamic>);

        followers.add(followingRelationship);
      }
      return followers;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error creating the relationship.");
      return followers;
    }
  }

  static Future<List<FollowingRelationship>> getFollowingFromUid(
    BuildContext context, {
    required String sourceId,
    required String? lastFollowingRelationshipID,
  }) async {
    List<FollowingRelationship> following = [];
    QuerySnapshot<Object?> querySnapshot;

    try {
      if (lastFollowingRelationshipID == null) {
        // First loading
        querySnapshot = await _followingRelationshipRef
            .where(FollowingRelationshipFields.sourceId, isEqualTo: sourceId)
            .orderBy(FollowingRelationshipFields.targetDisplayName, descending: false)
            .limit(20) // We only need to check if at least one document exists
            .get();
        AnalyticsService.logDatabaseRead(
          method: "FollowingRelationshipsDatabase.getFollowingFromUid.firstLoad",
          collection: "followingRelationships",
          documentCount: querySnapshot.docs.length,
          userId: sourceId,
          documentId: null,
        );
      } else {
        // Paginating
        final lastFollowingRelationshipDoc = await _followingRelationshipRef.doc(lastFollowingRelationshipID).get();

        if (!lastFollowingRelationshipDoc.exists) return [];

        querySnapshot = await _followingRelationshipRef
            .where(FollowingRelationshipFields.sourceId, isEqualTo: sourceId)
            .orderBy(FollowingRelationshipFields.targetDisplayName, descending: false)
            .startAfterDocument(lastFollowingRelationshipDoc)
            .limit(20)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "FollowingRelationshipsDatabase.getFollowingFromUid.paginate",
          collection: "followingRelationships",
          documentCount: querySnapshot.docs.length,
          userId: sourceId,
          documentId: null,
        );
      }

      for (var doc in querySnapshot.docs) {
        FollowingRelationship followingRelationship =
            FollowingRelationship.fromJSON(doc.data() as Map<String, dynamic>);

        following.add(followingRelationship);
      }
      return following;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error creating the relationship.");
      return following;
    }
  }

  // Read

  // Delete
}
