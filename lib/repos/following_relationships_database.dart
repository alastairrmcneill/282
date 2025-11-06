// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FollowingRelationshipsDatabase {
  static final _db = Supabase.instance.client;
  static final _followersRef = _db.from('followers');
  static final _followersViewRef = _db.from('vu_followers');

  static Future<bool> relationshipExists(
    BuildContext context, {
    required String sourceId,
    required String targetId,
  }) async {
    try {
      final response = await _followersRef
          .select()
          .eq(FollowingRelationshipFields.sourceId, sourceId)
          .eq(FollowingRelationshipFields.targetId, targetId);

      return response.isNotEmpty;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error checking the relationship.");
      return false;
    }
  }

  static Future create(
    BuildContext context, {
    required FollowingRelationship followingRelationship,
  }) async {
    try {
      await _followersRef.insert(followingRelationship.toJSON());
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error following the user.");
    }
  }

  static Future delete(BuildContext context, {required String sourceId, required String targetId}) async {
    try {
      await _followersRef
          .delete()
          .eq(FollowingRelationshipFields.sourceId, sourceId)
          .eq(FollowingRelationshipFields.targetId, targetId);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error unfollowing the user.");
    }
  }

  static Future<List<FollowingRelationship>> getFollowersFromUid(
    BuildContext context, {
    required String targetId,
    required List<String> excludedUserIds,
    int offset = 0,
  }) async {
    List<Map<String, dynamic>> response = [];
    List<FollowingRelationship> followers = [];
    int pageSize = 20;

    try {
      response = await _followersViewRef
          .select()
          .not(FollowingRelationshipFields.sourceId, 'in', excludedUserIds)
          .eq(FollowingRelationshipFields.targetId, targetId)
          .order(FollowingRelationshipFields.sourceDisplayName, ascending: true)
          .range(offset, offset + pageSize - 1);

      for (var doc in response) {
        FollowingRelationship followingRelationship = FollowingRelationship.fromJSON(doc);

        followers.add(followingRelationship);
      }
      return followers;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error finding your followers.");
      return followers;
    }
  }

  static Future<List<FollowingRelationship>> getFollowingFromUid(
    BuildContext context, {
    required String sourceId,
    required List<String> excludedUserIds,
    int offset = 0,
  }) async {
    List<Map<String, dynamic>> response = [];
    List<FollowingRelationship> following = [];
    int pageSize = 20;

    try {
      response = await _followersViewRef
          .select()
          .not(FollowingRelationshipFields.targetId, 'in', excludedUserIds)
          .eq(FollowingRelationshipFields.sourceId, sourceId)
          .order(FollowingRelationshipFields.targetDisplayName, ascending: true)
          .range(offset, offset + pageSize - 1);

      for (var doc in response) {
        FollowingRelationship followingRelationship = FollowingRelationship.fromJSON(doc);

        following.add(followingRelationship);
      }
      return following;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error creating the relationship.");
      return following;
    }
  }

  static Future<List<FollowingRelationship>> searchFollowingByUid(
    BuildContext context, {
    required String sourceId,
    required String searchTerm,
    int offset = 0,
  }) async {
    List<Map<String, dynamic>> response = [];
    List<FollowingRelationship> following = [];
    int pageSize = 20;

    try {
      response = await _followersViewRef
          .select()
          .eq(FollowingRelationshipFields.sourceId, sourceId)
          .ilike(FollowingRelationshipFields.targetSearchName, '%$searchTerm%')
          .order(FollowingRelationshipFields.targetDisplayName, ascending: true)
          .range(offset, offset + pageSize - 1);

      for (var doc in response) {
        FollowingRelationship followingRelationship = FollowingRelationship.fromJSON(doc);

        following.add(followingRelationship);
      }
      return following;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error searching friends.");
      return following;
    }
  }
}
