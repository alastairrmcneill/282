import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class NotificationsDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _notificationsRef = _db.collection('notifications');

  static Future<List<Notif>> readUserNotifs(
    BuildContext context, {
    required String userId,
    required String? lastNotificationId,
  }) async {
    List<Notif> notifications = [];
    QuerySnapshot querySnapshot;

    try {
      if (lastNotificationId == null) {
        // Load first batch
        querySnapshot = await _notificationsRef
            .where(NotifFields.targetId, isEqualTo: userId)
            .orderBy(NotifFields.dateTime, descending: true)
            .limit(20)
            .get();
        AnalyticsService.logDatabaseRead(
          method: "NotificationsDatabase.readUserNotifs.firstBatch",
          collection: "notifications",
          documentCount: querySnapshot.docs.length,
          userId: userId,
          documentId: null,
        );
      } else {
        final lastNotificationDoc = await _notificationsRef.doc(lastNotificationId).get();

        if (!lastNotificationDoc.exists) return [];

        querySnapshot = await _notificationsRef
            .where(NotifFields.targetId, isEqualTo: userId)
            .orderBy(NotifFields.dateTime, descending: true)
            .startAfterDocument(lastNotificationDoc)
            .limit(20)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "NotificationsDatabase.readUserNotifs.paginate",
          collection: "notifications",
          documentCount: querySnapshot.docs.length,
          userId: userId,
          documentId: null,
        );
      }

      for (var doc in querySnapshot.docs) {
        Notif notification = Notif.fromJSON(doc.data() as Map<String, dynamic>);

        notifications.add(notification);
      }

      return notifications;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error getting your notification.");
      return notifications;
    }
  }

  static Future updateNotif(BuildContext context, {required Notif notification}) async {
    try {
      DocumentReference ref = _notificationsRef.doc(notification.uid);

      await ref.update(notification.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error marking your notificaiton as done.");
    }
  }
}
