import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CommentsDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _commentsRef = _db.from('comments');
  static final SupabaseQueryBuilder _commentsViewRef = _db.from('vu_post_comments');

  // Create Comment
  static Future create(BuildContext context, {required Comment comment}) async {
    try {
      await _commentsRef.insert(comment.toJSON());
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error saving your comment.");
    }
  }

  // Update Comment
  static Future update(BuildContext context, {required Comment comment}) async {
    try {
      await _commentsRef.update(comment.toJSON());
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error updating your comment.");
    }
  }

  // Read comments from post
  static Future<List<Comment>> readPostComments(
    BuildContext context, {
    required String postId,
    required List<String> excludedAuthorIds,
    int offset = 0,
  }) async {
    List<Comment> comments = [];
    List<Map<String, dynamic>> response = [];
    int pageSize = 20;

    try {
      response = await _commentsViewRef
          .select()
          .not(CommentFields.authorId, 'in', excludedAuthorIds)
          .eq(CommentFields.postId, postId)
          .order(CommentFields.dateTime, ascending: false)
          .range(offset, offset + pageSize - 1);

      for (var doc in response) {
        Comment comment = Comment.fromJSON(doc);
        comments.add(comment);
      }
      return comments;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error getting your comments.");
      return comments;
    }
  }

  // Delete comment
  static Future deleteComment(BuildContext context, {required Comment comment}) async {
    try {
      await _commentsRef.delete().eq(CommentFields.uid, comment.uid ?? "");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error deleting your comment");
    }
  }
}
