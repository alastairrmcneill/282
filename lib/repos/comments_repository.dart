import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class CommentsRepository {
  final SupabaseClient _db;
  CommentsRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('comments');
  SupabaseQueryBuilder get _view => _db.from('vu_post_comments');

  // Create Comment
  Future<void> create({required Comment comment}) async {
    await _table.insert(comment.toJSON());
  }

  // Update Comment
  Future<void> update({required Comment comment}) async {
    await _table.update(comment.toJSON());
  }

  // Read comments from post
  Future<List<Comment>> readPostComments({
    required String postId,
    required List<String> excludedAuthorIds,
    int offset = 0,
  }) async {
    int pageSize = 10;
    final response = await _view
        .select()
        .not(CommentFields.authorId, 'in', excludedAuthorIds)
        .eq(CommentFields.postId, postId)
        .order(CommentFields.dateTime, ascending: false)
        .range(offset, offset + pageSize - 1);

    return response.map((doc) => Comment.fromJSON(doc)).toList();
  }

  // Delete comment
  Future deleteComment({required Comment comment}) async {
    await _table.delete().eq(CommentFields.uid, comment.uid ?? "");
  }
}
