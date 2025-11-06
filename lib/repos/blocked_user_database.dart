import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class BlockedUserDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _blockedUsersRef = _db.from('blocked_users');

  static Future<void> blockUser(BuildContext context,
      {required BlockedUserRelationship blockedUserRelationship}) async {
    try {
      await _blockedUsersRef.insert(blockedUserRelationship.toJSON());
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error blocking the user.");
    }
  }

  static Future<List<String>> getBlockedUsersForUid(BuildContext context, {required String userId}) async {
    List<Map<String, dynamic>> response = [];
    List<String> blockedUsers = [];

    try {
      response = await _blockedUsersRef.select().eq(BlockedUserRelationshipFields.userId, userId);

      for (var doc in response) {
        BlockedUserRelationship relationship = BlockedUserRelationship.fromJSON(doc);
        blockedUsers.add(relationship.blockedUserId);
      }

      return blockedUsers;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error blocking the user.");
      return [];
    }
  }
}
