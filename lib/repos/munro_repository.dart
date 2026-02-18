import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class MunroRepository {
  final SupabaseClient _db;
  MunroRepository(this._db);

  SupabaseQueryBuilder get _view => _db.from('vu_munros');

  Future<List<Munro>> getMunroData() async {
    final response = await _view.select();

    return response.map((item) => Munro.fromJSON(item)).toList();
  }
}
