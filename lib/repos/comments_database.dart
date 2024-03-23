import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CommentsDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _commentsRef = _db.collection('comments');

  // Create Comment
  static Future create(BuildContext context, {required Comment comment}) async {
    try {
      DocumentReference ref = _commentsRef.doc(comment.postId).collection('postComments').doc();

      Comment newComment = comment.copyWith(uid: ref.id);

      await ref.set(newComment.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error creating your comment.");
    }
  }

  // Update Comment
  static Future update(BuildContext context, {required Comment comment}) async {
    try {
      DocumentReference ref = _commentsRef.doc(comment.postId).collection('postComments').doc(comment.uid);

      await ref.update(comment.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error updating your comment.");
    }
  }

  // Read comment
  static Future<Comment?> readCommentFromUid(
    BuildContext context, {
    required String postId,
    required String commentId,
  }) async {
    try {
      DocumentReference ref = _commentsRef.doc(postId).collection('postComments').doc(commentId);
      DocumentSnapshot documentSnapshot = await ref.get();

      Map<String, Object?> data = documentSnapshot.data() as Map<String, Object?>;

      Comment comment = Comment.fromJSON(data);

      return comment;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error fetching your comment.");
      return null;
    }
  }

  // Read comments
  static Future<List<Comment>> readAllPostComment(BuildContext context, {required String postId}) async {
    List<Comment> comments = [];
    try {
      QuerySnapshot querySnapshot = await _commentsRef.doc(postId).collection('postComments').get();

      for (var doc in querySnapshot.docs) {
        Comment comment = Comment.fromJSON(doc.data() as Map<String, dynamic>);

        comments.add(comment);
      }

      return comments;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error fetching your comment.");
      return comments;
    }
  }

  static Future<List<Comment>> readPostComments(
    BuildContext context, {
    required String postId,
    required String? lastCommentId,
  }) async {
    List<Comment> comments = [];
    QuerySnapshot querySnapshot;

    if (lastCommentId == null) {
      // Load first bathc
      querySnapshot = await _commentsRef
          .doc(postId)
          .collection('postComments')
          .orderBy(PostFields.dateTime, descending: true)
          .limit(15)
          .get();
    } else {
      final lastCommentDoc = await _commentsRef.doc(postId).collection('postComments').doc(lastCommentId).get();

      if (!lastCommentDoc.exists) return [];

      querySnapshot = await _commentsRef
          .doc(postId)
          .collection('postComments')
          .orderBy(PostFields.dateTime, descending: true)
          .startAfterDocument(lastCommentDoc)
          .limit(15)
          .get();
    }

    for (var doc in querySnapshot.docs) {
      Comment comment = Comment.fromJSON(doc.data() as Map<String, dynamic>);

      comments.add(comment);
    }

    return comments;
  }

  // Delete comment
  static Future deleteComment(BuildContext context, {required Comment comment}) async {
    try {
      DocumentReference ref = _commentsRef.doc(comment.postId).collection('postComments').doc(comment.uid!);

      await ref.delete();
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error deleting your comment");
    }
  }
}
