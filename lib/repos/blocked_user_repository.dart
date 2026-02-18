import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class BlockedUserRepository {
  final SupabaseClient _db;

  BlockedUserRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('blocked_users');

  Future<void> blockUser({required BlockedUserRelationship blockedUserRelationship}) async {
    await _table.insert(blockedUserRelationship.toJSON());
  }

  Future<List<String>> getBlockedUsersForUid({required String userId}) async {
    final response = await _table.select().eq(BlockedUserRelationshipFields.userId, userId);
    return response.map((doc) => BlockedUserRelationship.fromJSON(doc).blockedUserId).toList();
  }
}
