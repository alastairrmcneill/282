import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class UserRepository {
  final SupabaseClient _db;

  UserRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('users');

  // Create user
  Future<void> create({required AppUser appUser}) async {
    final response = await _table.select().eq(AppUserFields.uid, appUser.uid ?? "").maybeSingle();

    if (response == null) {
      await _table.insert(appUser.toJSON());
    }
  }

  // Update user
  Future<void> update({required AppUser appUser}) async {
    await _table.update(appUser.toJSON()).eq(AppUserFields.uid, appUser.uid ?? "");
  }

  // Delete user
  Future deleteUserWithUID({required String uid}) async {
    await _table.delete().eq(AppUserFields.uid, uid);
  }

  // Read single user
  Future<AppUser?> readUserFromUid({required String uid}) async {
    final response = await _table.select().eq(AppUserFields.uid, uid).single();
    return AppUser.fromJSON(response);
  }

  // Read multiple users
  Future<List<AppUser>> readUsersByName({
    required String searchTerm,
    required List<String> excludedAuthorIds,
    int offset = 0,
  }) async {
    int pageSize = 30;

    final response = await _table
        .select()
        .ilike(AppUserFields.searchName, '%$searchTerm%')
        .not(AppUserFields.uid, 'in', excludedAuthorIds)
        .eq(AppUserFields.profileVisibility, Privacy.public)
        .order(AppUserFields.searchName, ascending: true)
        .range(offset, offset + pageSize - 1);

    return response.map((e) => AppUser.fromJSON(e)).toList();
  }

  Future<List<AppUser>> readUsersFromUids({required List<String> uids}) async {
    List<Map<String, dynamic>> response = [];

    if (uids.isEmpty) return [];

    response = await _table.select().inFilter(AppUserFields.uid, uids);

    return response.map((e) => AppUser.fromJSON(e)).toList();
  }
}
