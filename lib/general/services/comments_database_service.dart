import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

class CommentsDatabaseService {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _commentsRef = _db.collection('comments');

  // Create Comment
  static Future create(BuildContext context, {required Comment comment}) async {
    try {
      DocumentReference ref = _commentsRef.doc(comment.postId).collection('postComments').doc();

      Comment newComment = comment.copyWith(uid: ref.id);

      await ref.set(newComment.toJSON());
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error creating your comment.");
    }
  }

  // Update Comment
  static Future update(BuildContext context, {required Comment comment}) async {
    try {
      DocumentReference ref = _commentsRef.doc(comment.postId).collection('postComments').doc(comment.uid);

      await ref.update(comment.toJSON());
    } on FirebaseException catch (error) {
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
    } on FirebaseException catch (error) {
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
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error fetching your comment.");
      return comments;
    }
  }

  // Delete comment
  static Future deleteComment(BuildContext context, {required Comment comment}) async {
    try {
      DocumentReference ref = _commentsRef.doc(comment.postId).collection('postComments').doc(comment.uid!);

      await ref.delete();
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error deleting your comment");
    }
  }
}
