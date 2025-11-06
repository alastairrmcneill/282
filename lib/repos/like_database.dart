// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class LikeDatabase {
  static final _db = Supabase.instance.client;
  static final _likesRef = _db.from('likes');
  static final _likesViewRef = _db.from('vu_likes');

  static Future create(
    BuildContext context, {
    required Like like,
  }) async {
    try {
      await _likesRef.insert(like.toJSON());
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error liking this post.");
    }
  }

  static Future delete(
    BuildContext context, {
    required String postId,
    required String userId,
  }) async {
    try {
      await _likesRef.delete().eq(LikeFields.postId, postId).eq(LikeFields.userId, userId);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error unliking this post.");
    }
  }

  static Future<Set<String>> getLikedPostIds({
    required String userId,
    required List<Post> posts,
  }) async {
    final Set<String> postIds = {};

    try {
      final postIdList = posts.map((post) => post.uid).toList();
      final response = await _likesRef.select().inFilter(LikeFields.postId, postIdList).eq(LikeFields.userId, userId);

      for (final row in response) {
        postIds.add(row[LikeFields.postId]);
      }

      return postIds;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      return postIds;
    }
  }

  static Future<List<Like>> readPostLikes({
    required String postId,
    required List<String>? excludedUserIds,
    int offset = 0,
  }) async {
    List<Map<String, dynamic>> response = [];
    List<Like> likes = [];
    int pageSize = 30;

    try {
      response = await _likesViewRef
          .select()
          .eq(LikeFields.postId, postId)
          .not(LikeFields.userId, 'in', excludedUserIds)
          .order(LikeFields.dateTimeCreated, ascending: false)
          .range(offset, offset + pageSize - 1);

      for (var doc in response) {
        Like like = Like.fromJSON(doc);

        likes.add(like);
      }

      return likes;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      return likes;
    }
  }
}
