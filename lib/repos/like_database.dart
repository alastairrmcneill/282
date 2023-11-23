// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
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

      await ref.set(like.toJSON());
    } on FirebaseException catch (error) {
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
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error deleting the like.");
    }
  }

  static Future<Set<String>> getLikedPostIds({
    required String userId,
    required List<Post> posts,
  }) async {
    final Set<String> postIds = {};
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
  }
}
