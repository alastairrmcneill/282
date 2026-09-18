import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class MunroMatchesRepository {
  final SupabaseClient _db;
  MunroMatchesRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('munro_matches');

  Stream<List<MunroMatch>> subscribeToUserMunroMatches({required String userId}) {
    return _table
        .stream(primaryKey: [MunroMatchFields.id])
        .eq(MunroMatchFields.userId, userId)
        .order(MunroMatchFields.detectedAt, ascending: false)
        .map((rows) => rows.map(MunroMatch.fromJSON).toList());
  }

  Future<List<PendingActivityReview>> getUsersPendingActivityReviews({required String userId}) async {
    final response = await _table
        .select('*, strava_activities(*)')
        .eq(MunroMatchFields.userId, userId)
        .eq(MunroMatchFields.status, MunroMatchStatus.pending.toJsonString())
        .order(MunroMatchFields.detectedAt, ascending: false);

    final matchesByActivityId = <int, List<MunroMatch>>{};
    final activitiesById = <int, StravaActivity>{};

    for (final row in response) {
      final match = MunroMatch.fromJSON(row);
      final activity = StravaActivity.fromJSON(row['strava_activities'] as Map<String, dynamic>);
      matchesByActivityId.putIfAbsent(match.stravaActivityId, () => []).add(match);
      activitiesById.putIfAbsent(match.stravaActivityId, () => activity);
    }

    return activitiesById.entries
        .map((e) => PendingActivityReview(activity: e.value, matches: matchesByActivityId[e.key]!))
        .toList();
  }

  Future<void> updateMatchesStatus({
    required List<String> matchIds,
    required MunroMatchStatus status,
  }) async {
    if (matchIds.isEmpty) return;
    await _table.update({
      MunroMatchFields.status: status.toJsonString(),
      MunroMatchFields.reviewedAt: DateTime.now().toIso8601String(),
    }).inFilter(MunroMatchFields.id, matchIds);
  }
}
