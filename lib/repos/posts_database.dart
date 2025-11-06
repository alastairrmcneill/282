import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PostsDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _postsTableRef = _db.from('posts');
  static final SupabaseQueryBuilder _postsViewRef = _db.from('vu_posts');
  static final SupabaseQueryBuilder _globalFeedViewRef = _db.from('vu_global_feed');
  static final SupabaseQueryBuilder _friendsFeedViewRef = _db.from('vu_friends_feed');

  // Create Post
  static Future<String> create(BuildContext context, {required Post post}) async {
    try {
      final response = await _postsTableRef.insert(post.toJSON()).select(PostFields.uid).single();

      return response[PostFields.uid] as String;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error creating your post.");
      return "";
    }
  }

  // Update Post
  static Future update(BuildContext context, {required Post post}) async {
    try {
      await _postsTableRef.update(post.toJSON()).eq(PostFields.uid, post.uid);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error updating your post.");
    }
  }

  // Read post
  static Future<Post?> readPostFromUid(BuildContext context, {required String uid}) async {
    Map<String, dynamic>? response = {};
    Post? post;
    try {
      response = await _postsViewRef.select().eq(PostFields.uid, uid).maybeSingle();

      if (response == null) return post;

      post = Post.fromJSON(response);

      return post;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error fetching your post.");
      return post;
    }
  }

  // Read posts from user id
  static Future<List<Post>> readPostsFromUserId(
    BuildContext context, {
    required String userId,
    int offset = 0,
  }) async {
    List<Post> posts = [];
    List<Map<String, dynamic>> response = [];
    int pageSize = 10;

    try {
      response = await _postsViewRef
          .select()
          .eq(PostFields.authorId, userId)
          .order(PostFields.dateTimeCreated, ascending: false)
          .range(offset, offset + pageSize - 1);

      for (var doc in response) {
        Post post = Post.fromJSON(doc);
        posts.add(post);
      }

      return posts;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an issue getting the posts.");
      return [];
    }
  }

  // Get friends feed
  static Future getFriendsFeedFromUserId(
    BuildContext context, {
    required String userId,
    required List<String> excludedAuthorIds,
    int offset = 0,
  }) async {
    List<Map<String, dynamic>> response = [];
    List<Post> posts = [];
    int pageSize = 10;

    try {
      response = await _friendsFeedViewRef
          .select()
          .not(PostFields.authorId, 'in', excludedAuthorIds)
          .eq(PostFields.userId, userId)
          .order(PostFields.dateTimeCreated, ascending: false)
          .range(offset, offset + pageSize - 1)
          .timeout(Duration(seconds: 30));

      for (var doc in response) {
        Post post = Post.fromJSON(doc);
        posts.add(post);
      }

      return posts;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error getting the posts. Please try again.");
      return posts;
    }
  }

  // Get global feed
  static Future getGlobalFeed(
    BuildContext context, {
    required List<String> excludedAuthorIds,
    int offset = 0,
  }) async {
    List<Map<String, dynamic>> response = [];
    List<Post> posts = [];
    int pageSize = 10;

    try {
      response = await _globalFeedViewRef
          .select()
          .not(PostFields.authorId, 'in', excludedAuthorIds)
          .order(PostFields.dateTimeCreated, ascending: false)
          .range(offset, offset + pageSize - 1)
          .timeout(Duration(seconds: 30));

      for (var doc in response) {
        Post post = Post.fromJSON(doc);
        posts.add(post);
      }

      return posts;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error getting the posts. Please try again.");
      return posts;
    }
  }

  // Delete post
  static Future deletePostWithUID(BuildContext context, {required String uid}) async {
    try {
      await _postsTableRef.delete().eq(PostFields.uid, uid);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error deleting your post");
    }
  }
}
