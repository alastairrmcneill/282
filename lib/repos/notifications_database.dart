import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class NotificationsDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _notificationsViewRef = _db.from('vu_notifications');

  static Future<List<Notif>> readUserNotifs(
    BuildContext context, {
    required String userId,
    List<String>? excludedSourceIds,
    int offset = 0,
  }) async {
    List<Map<String, dynamic>> response = [];
    List<Notif> notifications = [];
    int pageSize = 20;

    try {
      response = await _notificationsViewRef
          .select()
          .not(NotifFields.sourceId, 'in', excludedSourceIds ?? [])
          .eq(NotifFields.targetId, userId)
          .order(NotifFields.dateTime, ascending: false)
          .range(offset, offset + pageSize - 1);

      for (var doc in response) {
        Notif notification = Notif.fromJSON(doc);

        notifications.add(notification);
      }

      return notifications;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error getting your notifications.");
      return notifications;
    }
  }

  static Future updateNotif(BuildContext context, {required Notif notification}) async {
    try {
      await _notificationsViewRef.update(notification.toJSON()).eq(NotifFields.uid, notification.uid);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error marking your notification as done.");
    }
  }
}
