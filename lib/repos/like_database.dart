// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/log_service.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class LikeDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _likesRef = _db.collection('likes');

  static Future create(
    BuildContext context, {
    required Like like,
  }) async {
    try {
      DocumentReference ref = _likesRef.doc();

      Like newLike = like.copyWith(uid: ref.id);

      await ref.set(newLike.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error creating the like.");
    }
  }

  static Future delete(
    BuildContext context, {
    required String postId,
    required String userId,
  }) async {
    try {
      QuerySnapshot<Object?> querySnapshot = await _likesRef
          .where(LikeFields.postId, isEqualTo: postId)
          .where(LikeFields.userId, isEqualTo: userId)
          .limit(1) // We only need to check if at least one document exists
          .get();

      await querySnapshot.docs[0].reference.delete();
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error deleting the like.");
    }
  }

  static Future<Set<String>> getLikedPostIds({
    required String userId,
    required List<Post> posts,
  }) async {
    final Set<String> postIds = {};

    try {
      for (final Post post in posts) {
        final likeDocs = await _likesRef
            .where(LikeFields.postId, isEqualTo: post.uid)
            .where(LikeFields.userId, isEqualTo: userId)
            .limit(1)
            .get();
        if (likeDocs.docs.isNotEmpty) {
          if (likeDocs.docs[0].exists) {
            postIds.add(post.uid!);
          }
        }
      }

      return postIds;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      return postIds;
    }
  }

  static Future<List<Like>> readPostLikes({required String postId, required String? lastLikeId}) async {
    List<Like> likes = [];
    QuerySnapshot querySnapshot;

    try {
      if (lastLikeId == null) {
        // Load first batch
        querySnapshot = await _likesRef
            .where(LikeFields.postId, isEqualTo: postId)
            .orderBy(LikeFields.userDisplayName, descending: true)
            .limit(30)
            .get();
      } else {
        final lastLikeDoc = await _likesRef.doc(lastLikeId).get();

        if (!lastLikeDoc.exists) return [];

        querySnapshot = await _likesRef
            .where(LikeFields.postId, isEqualTo: postId)
            .orderBy(LikeFields.userDisplayName, descending: true)
            .startAfterDocument(lastLikeDoc)
            .limit(30)
            .get();
      }

      for (var doc in querySnapshot.docs) {
        Like like = Like.fromJSON(doc.data() as Map<String, dynamic>);

        likes.add(like);
      }

      return likes;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      return likes;
    }
  }
}
