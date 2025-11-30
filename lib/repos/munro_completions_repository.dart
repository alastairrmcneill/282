import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class MunroCompletionsRepository {
  final SupabaseClient _db;
  MunroCompletionsRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('munro_completions');

  Future<void> create(List<MunroCompletion> munroCompletions) async {
    await _table.insert(munroCompletions.map((e) => e.toJSON()).toList());
  }

  Future<List<MunroCompletion>> getUserMunroCompletions({required String userId}) async {
    final response = await _table
        .select()
        .eq(MunroCompletionFields.userId, userId)
        .order(MunroCompletionFields.dateTimeCompleted, ascending: false);

    return response.map((doc) => MunroCompletion.fromJSON(doc)).toList();
  }

  Future<List<MunroCompletion>> getMunroCompletionsFromUserList({required List<String> userIds}) async {
    final response = await _table.select().inFilter(MunroCompletionFields.userId, userIds);
    return response.map((doc) => MunroCompletion.fromJSON(doc)).toList();
  }

  Future<void> delete({required String munroCompletionId}) async {
    await _table.delete().eq(MunroCompletionFields.id, munroCompletionId);
  }

  Future<void> deleteByMunroIdsAndPostId({
    required List<int> munroIds,
    required String postId,
  }) async {
    await _table.delete().eq(MunroCompletionFields.postId, postId).inFilter(MunroCompletionFields.munroId, munroIds);
  }
}
