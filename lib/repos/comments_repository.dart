import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class CommentsRepository {
  final SupabaseClient _db;
  CommentsRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('comments');
  SupabaseQueryBuilder get _view => _db.from('vu_post_comments');

  // Create Comment
  // Returns the persisted comment (including its server-generated id) so callers
  // can use it for any immediate follow-up action (e.g. deleting it again).
  Future<Comment> create({required Comment comment}) async {
    final response = await _table.insert(comment.toJSON()).select().single();
    return Comment.fromJSON(response);
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
    final uid = comment.uid;
    if (uid == null) {
      // Nothing was ever persisted for this comment (e.g. the create() call that
      // should have populated it hasn't completed/succeeded) — there's nothing to
      // delete server-side. Sending "" here previously reached Postgres as
      // `invalid input syntax for type uuid: ""`.
      return;
    }
    await _table.delete().eq(CommentFields.uid, uid);
  }
}
