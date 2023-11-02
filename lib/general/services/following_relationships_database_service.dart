// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

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
    } on FirebaseException catch (error) {
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

      await querySnapshot.docs[0].reference.delete();
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error deleting the relationship.");
    }
  }

  static Future getFollowersFromUid(BuildContext context, {required String targetId}) async {
    FollowingState followingState = Provider.of<FollowingState>(context, listen: false);

    QuerySnapshot<Object?> querySnapshot = await _followingRelationshipRef
        .where(FollowingRelationshipFields.targetId, isEqualTo: targetId)
        .limit(10) // We only need to check if at least one document exists
        .get();

    List<FollowingRelationship> followers = [];
    for (var doc in querySnapshot.docs) {
      FollowingRelationship followingRelationship = FollowingRelationship.fromJSON(doc.data() as Map<String, dynamic>);

      followers.add(followingRelationship);
    }
    followingState.setMyFollowers = followers;
  }

  static Future getFollowingFromUid(BuildContext context, {required String sourceId}) async {
    FollowingState followingState = Provider.of<FollowingState>(context, listen: false);

    QuerySnapshot<Object?> querySnapshot = await _followingRelationshipRef
        .where(FollowingRelationshipFields.sourceId, isEqualTo: sourceId)
        .limit(10) // We only need to check if at least one document exists
        .get();

    List<FollowingRelationship> following = [];
    for (var doc in querySnapshot.docs) {
      FollowingRelationship followingRelationship = FollowingRelationship.fromJSON(doc.data() as Map<String, dynamic>);

      following.add(followingRelationship);
    }

    followingState.setMyFollowing = following;
  }

  // Read

  // Delete
}
