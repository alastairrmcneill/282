import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/models/strava_matching_config_model.dart';

class StravaMatchingConfigRepository {
  final SupabaseClient _db;
  StravaMatchingConfigRepository(this._db);
  SupabaseQueryBuilder get _table => _db.from('strava_matching_config');

  Future<StravaMatchingConfig> getStravaMatchingConfig() async {
    final response = await _table.select().eq(StravaMatchingConfigFields.id, 1).single();
    return StravaMatchingConfig.fromJson(response);
  }
}
