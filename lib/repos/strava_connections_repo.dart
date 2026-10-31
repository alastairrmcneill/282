import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class StravaConnectionsRepository {
  final SupabaseClient _db;

  StravaConnectionsRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('strava_connections');

  Future<StravaConnection?> stravaConnectionForUser({required String userId}) async {
    final response = await _table.select().eq(StravaConnectionFields.userId, userId).maybeSingle();
    return response != null ? StravaConnection.fromJSON(response) : null;
  }
}
