import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class NotificationsRepository {
  final SupabaseClient _db;
  NotificationsRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('notifications');
  SupabaseQueryBuilder get _view => _db.from('vu_notifications');

  Future<List<Notif>> readUserNotifs({
    required String userId,
    List<String>? excludedSourceIds,
    int offset = 0,
  }) async {
    int pageSize = 100;

    final response = await _view
        .select()
        .not(NotifFields.sourceId, 'in', excludedSourceIds ?? [])
        .eq(NotifFields.targetId, userId)
        .order(NotifFields.read, ascending: true)
        .order(NotifFields.dateTime, ascending: false)
        .range(offset, offset + pageSize - 1);

    return response.map((doc) => Notif.fromJSON(doc)).toList();
  }

  Future updateNotif({required Notif notification}) async {
    await _table.update(notification.toJSON()).eq(NotifFields.uid, notification.uid);
  }
}
