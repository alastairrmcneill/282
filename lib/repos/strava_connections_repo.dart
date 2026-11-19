import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class StravaConnectionsRepository {
  final SupabaseClient _db;

  StravaConnectionsRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('strava_connections');

  Future<StravaConnection?> stravaConnectionForUser({required String userId}) async {
    final response =
        await _table.select(StravaConnectionFields.selectable).eq(StravaConnectionFields.userId, userId).maybeSingle();
    return response != null ? StravaConnection.fromJSON(response) : null;
  }

  Future<StravaDataDeletion?> latestDeletionForUser({required String userId}) async {
    final response = await _db
        .from('strava_data_deletions')
        .select()
        .eq(StravaDataDeletionFields.userId, userId)
        .order(StravaDataDeletionFields.completedAt, ascending: false)
        .limit(1)
        .maybeSingle();
    return response != null ? StravaDataDeletion.fromJSON(response) : null;
  }
}
