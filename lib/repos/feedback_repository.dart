import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class FeedbackRepository {
  final SupabaseClient _db;
  FeedbackRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('app_feedbacks');

  Future<void> create({required AppFeedback feedback}) async {
    await _table.insert(feedback.toJSON());
  }
}
