import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class PostsRepository {
  final SupabaseClient _db;
  PostsRepository(this._db);

  SupabaseQueryBuilder get _postsTableRef => _db.from('posts');
  SupabaseQueryBuilder get _postsViewRef => _db.from('vu_posts');

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
  // Keyset pagination: [lastPost] is the final post of the previous page
  // (null for the first page).
  Future<List<Post>> readPostsFromUserId({
    required String userId,
    Post? lastPost,
  }) async {
    final List<dynamic> response = await _db.rpc(
      'get_user_posts',
      params: {
        'p_user_id': userId,
        'p_limit': 10,
        'p_before_date_time': lastPost?.dateTimeCreated.toUtc().toIso8601String(),
        'p_before_id': lastPost?.uid,
      },
    );

    return response.map((doc) => Post.fromJSON(doc as Map<String, dynamic>)).toList();
  }

  // Get friends feed (caller identity comes from the JWT server-side)
  Future<List<Post>> getFriendsFeed({
    required List<String> excludedAuthorIds,
    Post? lastPost,
  }) async {
    final List<dynamic> response = await _db.rpc(
      'get_friends_feed',
      params: {
        'p_limit': 10,
        'p_before_date_time': lastPost?.dateTimeCreated.toUtc().toIso8601String(),
        'p_before_id': lastPost?.uid,
        'p_excluded_author_ids': excludedAuthorIds,
      },
    ).timeout(Duration(seconds: 30));

    return response.map((doc) => Post.fromJSON(doc as Map<String, dynamic>)).toList();
  }

  // Get global feed
  Future<List<Post>> getGlobalFeed({
    required List<String> excludedAuthorIds,
    Post? lastPost,
  }) async {
    final List<dynamic> response = await _db.rpc(
      'get_global_feed',
      params: {
        'p_limit': 10,
        'p_before_date_time': lastPost?.dateTimeCreated.toUtc().toIso8601String(),
        'p_before_id': lastPost?.uid,
        'p_excluded_author_ids': excludedAuthorIds,
      },
    ).timeout(Duration(seconds: 30));

    return response.map((doc) => Post.fromJSON(doc as Map<String, dynamic>)).toList();
  }

  // Delete post
  Future deletePostWithUID({required String uid}) async {
    await _postsTableRef.delete().eq(PostFields.uid, uid);
  }
}
