import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class ReportRepository {
  final SupabaseClient _db;
  ReportRepository(this._db);
  SupabaseQueryBuilder get _table => _db.from('reports');

  Future<void> create({required Report report}) async {
    await _table.insert(report.toJSON());
  }
}
