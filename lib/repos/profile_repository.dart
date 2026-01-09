import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class ProfileRepository {
  final SupabaseClient _db;

  ProfileRepository(this._db);

  SupabaseQueryBuilder get _view => _db.from('vu_profiles');

  Future<Profile> getProfileFromUserId({required String userId}) async {
    final response = await _view.select().eq(AppUserFields.uid, userId).single();

    return Profile.fromJSON(response);
  }
}
