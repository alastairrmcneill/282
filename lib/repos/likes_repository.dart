import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class LikesRepository {
  final SupabaseClient _db;
  LikesRepository(this._db);
  SupabaseQueryBuilder get _table => _db.from('likes');
  SupabaseQueryBuilder get _view => _db.from('vu_likes');

  Future create({required Like like}) async {
    await _table.insert(like.toJSON());
  }

  Future delete({
    required String postId,
    required String userId,
  }) async {
    await _table.delete().eq(LikeFields.postId, postId).eq(LikeFields.userId, userId);
  }

  Future<Set<String>> getLikedPostIds({
    required String userId,
    required List<Post> posts,
  }) async {
    final Set<String> postIds = {};

    final postIdList = posts.map((post) => post.uid).toList();
    final response = await _table.select().inFilter(LikeFields.postId, postIdList).eq(LikeFields.userId, userId);

    for (final doc in response) {
      postIds.add(doc[LikeFields.postId]);
    }

    return postIds;
  }

  Future<List<Like>> readPostLikes({
    required String postId,
    required List<String>? excludedUserIds,
    int offset = 0,
  }) async {
    int pageSize = 30;

    final response = await _view
        .select()
        .eq(LikeFields.postId, postId)
        .not(LikeFields.userId, 'in', excludedUserIds)
        .order(LikeFields.dateTimeCreated, ascending: false)
        .range(offset, offset + pageSize - 1);

    return response.map((doc) => Like.fromJSON(doc)).toList();
  }
}
