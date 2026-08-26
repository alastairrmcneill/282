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

  Future<List<MunroMatch>> getPendingUserMunroMatches({required String userId}) async {
    final response = await _table
        .select()
        .eq(MunroMatchFields.userId, userId)
        .eq(MunroMatchFields.status, MunroMatchStatus.pending.toString())
        .order(MunroMatchFields.detectedAt, ascending: false);

    return response.map((e) => MunroMatch.fromJSON(e)).toList();
  }
}
