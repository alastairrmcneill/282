import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class FollowersRepository {
  final SupabaseClient _db;
  FollowersRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('followers');
  SupabaseQueryBuilder get _view => _db.from('vu_followers');

  Future<bool> relationshipExists({
    required String sourceId,
    required String targetId,
  }) async {
    final response = await _table
        .select()
        .eq(FollowingRelationshipFields.sourceId, sourceId)
        .eq(FollowingRelationshipFields.targetId, targetId);

    return response.isNotEmpty;
  }

  Future create({required FollowingRelationship followingRelationship}) async {
    await _table.insert(followingRelationship.toJSON());
  }

  Future delete({required String sourceId, required String targetId}) async {
    await _table
        .delete()
        .eq(FollowingRelationshipFields.sourceId, sourceId)
        .eq(FollowingRelationshipFields.targetId, targetId);
  }

  Future<List<FollowingRelationship>> getFollowersFromUid({
    required String targetId,
    required List<String> excludedUserIds,
    int offset = 0,
  }) async {
    int pageSize = 20;

    final response = await _view
        .select()
        .not(FollowingRelationshipFields.sourceId, 'in', excludedUserIds)
        .eq(FollowingRelationshipFields.targetId, targetId)
        .order(FollowingRelationshipFields.sourceDisplayName, ascending: true)
        .range(offset, offset + pageSize - 1);

    return response.map((doc) => FollowingRelationship.fromJSON(doc)).toList();
  }

  Future<List<FollowingRelationship>> getFollowingFromUid({
    required String sourceId,
    required List<String> excludedUserIds,
    int offset = 0,
  }) async {
    int pageSize = 20;

    final response = await _view
        .select()
        .not(FollowingRelationshipFields.targetId, 'in', excludedUserIds)
        .eq(FollowingRelationshipFields.sourceId, sourceId)
        .order(FollowingRelationshipFields.targetDisplayName, ascending: true)
        .range(offset, offset + pageSize - 1);

    return response.map((doc) => FollowingRelationship.fromJSON(doc)).toList();
  }

  Future<List<FollowingRelationship>> getAllFollowingFromUid({
    required String sourceId,
    required List<String> excludedUserIds,
  }) async {
    const int pageSize = 1000;
    int offset = 0;

    final List<FollowingRelationship> all = [];

    while (true) {
      final response = await _view
          .select()
          .not(FollowingRelationshipFields.targetId, 'in', excludedUserIds)
          .eq(FollowingRelationshipFields.sourceId, sourceId)
          .order(FollowingRelationshipFields.targetDisplayName, ascending: true)
          .range(offset, offset + pageSize - 1);

      final page = response.map((doc) => FollowingRelationship.fromJSON(doc)).toList();

      all.addAll(page);

      // If we got fewer than pageSize rows, we've reached the end.
      if (page.length < pageSize) break;

      offset += pageSize;
    }

    return all;
  }

  Future<List<FollowingRelationship>> searchFollowing({
    required String sourceId,
    required String searchTerm,
    int offset = 0,
  }) async {
    int pageSize = 20;

    final response = await _view
        .select()
        .eq(FollowingRelationshipFields.sourceId, sourceId)
        .ilike(FollowingRelationshipFields.targetSearchName, '%$searchTerm%')
        .order(FollowingRelationshipFields.targetDisplayName, ascending: true)
        .range(offset, offset + pageSize - 1);

    return response.map((doc) => FollowingRelationship.fromJSON(doc)).toList();
  }
}
