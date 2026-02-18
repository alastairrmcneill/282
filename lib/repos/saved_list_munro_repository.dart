import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class SavedListMunroRepository {
  final SupabaseClient _db;
  SavedListMunroRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('saved_list_munros');

  Future create({required SavedListMunro savedListMunro}) async {
    await _table.insert(savedListMunro.toJSON());
  }

  Future delete({required String savedListId, required int munroId}) async {
    await _table.delete().eq(SavedListMunroFields.savedListId, savedListId).eq(SavedListMunroFields.munroId, munroId);
  }
}
