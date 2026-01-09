import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class SavedListRepository {
  final SupabaseClient _db;
  SavedListRepository(this._db);
  SupabaseQueryBuilder get _table => _db.from('saved_lists');
  SupabaseQueryBuilder get _view => _db.from('vu_saved_lists');

  Future<SavedList> create({required SavedList savedList}) async {
    Map<String, Object?> response = await _table.insert(savedList.toJSON()).select().single();
    return SavedList.fromJSON(response);
  }

  Future<SavedList?> readFromUid({required String uid}) async {
    Map<String, Object?> response = await _view.select().eq(SavedListFields.uid, uid).single();

    return SavedList.fromJSON(response);
  }

  Future<List<SavedList>> readFromUserUid({required String userUid}) async {
    final response = await _view
        .select()
        .eq(SavedListFields.userId, userUid)
        .order(SavedListFields.dateTimeCreated, ascending: false);

    return response.map((doc) => SavedList.fromJSON(doc)).toList();
  }

  Future<void> update({required SavedList savedList}) async {
    await _table.update(savedList.toJSON()).eq(SavedListFields.uid, savedList.uid ?? "");
  }

  Future<void> deleteFromUid({required String uid}) async {
    await _table.delete().eq(SavedListFields.uid, uid);
  }
}
