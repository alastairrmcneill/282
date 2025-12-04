import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class PostsRepository {
  final SupabaseClient _db;
  PostsRepository(this._db);

  SupabaseQueryBuilder get _postsTableRef => _db.from('posts');
  SupabaseQueryBuilder get _postsViewRef => _db.from('vu_posts');
  SupabaseQueryBuilder get _globalFeedViewRef => _db.from('vu_global_feed');
  SupabaseQueryBuilder get _friendsFeedViewRef => _db.from('vu_friends_feed');

  // Create Post
  Future<String> create({required Post post}) async {
    final response = await _postsTableRef.insert(post.toJSON()).select(PostFields.uid).single();
    return response[PostFields.uid] as String;
  }

  // Update Post
  Future update({required Post post}) async {
    await _postsTableRef.update(post.toJSON()).eq(PostFields.uid, post.uid);
  }

  // Read post
  Future<Post?> readPostFromUid({required String uid}) async {
    final response = await _postsViewRef.select().eq(PostFields.uid, uid).maybeSingle();

    if (response == null) return null;

    return Post.fromJSON(response);
  }

  // Read posts from user id
  Future<List<Post>> readPostsFromUserId({
    required String userId,
    int offset = 0,
  }) async {
    int pageSize = 10;

    final response = await _postsViewRef
        .select()
        .eq(PostFields.authorId, userId)
        .order(PostFields.dateTimeCreated, ascending: false)
        .range(offset, offset + pageSize - 1);

    return response.map((doc) => Post.fromJSON(doc)).toList();
  }

  // Get friends feed
  Future<List<Post>> getFriendsFeedFromUserId({
    required String userId,
    required List<String> excludedAuthorIds,
    int offset = 0,
  }) async {
    int pageSize = 10;

    final response = await _friendsFeedViewRef
        .select()
        .not(PostFields.authorId, 'in', excludedAuthorIds)
        .eq(PostFields.userId, userId)
        .order(PostFields.dateTimeCreated, ascending: false)
        .range(offset, offset + pageSize - 1)
        .timeout(Duration(seconds: 30));

    return response.map((doc) => Post.fromJSON(doc)).toList();
  }

  // Get global feed
  Future<List<Post>> getGlobalFeed({
    required List<String> excludedAuthorIds,
    int offset = 0,
  }) async {
    int pageSize = 10;

    final response = await _globalFeedViewRef
        .select()
        .not(PostFields.authorId, 'in', excludedAuthorIds)
        .order(PostFields.dateTimeCreated, ascending: false)
        .range(offset, offset + pageSize - 1)
        .timeout(Duration(seconds: 30));
    return response.map((doc) => Post.fromJSON(doc)).toList();
  }

  // Delete post
  Future deletePostWithUID({required String uid}) async {
    await _postsTableRef.delete().eq(PostFields.uid, uid);
  }
}
