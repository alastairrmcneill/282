import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';

class ProfileDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _profilesViewRef = _db.from('vu_profiles');

  static Future<Profile> getProfileFromUserId({required String userId}) async {
    try {
      final response = await _profilesViewRef.select().eq(AppUserFields.uid, userId).single();

      Profile profile = Profile.fromJSON(response);

      return profile;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }
}
