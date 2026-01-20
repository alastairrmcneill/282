import 'package:supabase_flutter/supabase_flutter.dart';

class GlobalCompletionCountRepository {
  final SupabaseClient _db;

  GlobalCompletionCountRepository(this._db);

  SupabaseQueryBuilder get _view => _db.from('vu_global_completion_count');

  Future<int> getGlobalCompletionCount() async {
    final response = await _view.select();
    if (response.isEmpty) {
      return -1;
    }
    return response[0][AllCompletionsFields.totalCompletions] as int;
  }
}

class AllCompletionsFields {
  static const String totalCompletions = 'total_completions';
}
