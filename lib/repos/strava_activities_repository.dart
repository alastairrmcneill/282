import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class StravaActivitiesRepository {
  final SupabaseClient _db;

  StravaActivitiesRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('strava_activities');

  Future<List<StravaActivity>> cachedActivitiesForUser({required String userId}) async {
    final response = await _table
        .select()
        .eq(StravaActivityFields.userId, userId)
        .order(StravaActivityFields.startDate, ascending: false);
    return response.map(StravaActivity.fromJSON).toList();
  }
}
