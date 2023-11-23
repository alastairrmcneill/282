import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

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

    if (lastNotificationId == null) {
      // Load first batch
      querySnapshot = await _notificationsRef
          .where(NotifFields.targetId, isEqualTo: userId)
          .orderBy(NotifFields.postId, descending: true)
          .limit(10)
          .get();
    } else {
      final lastNotificationDoc = await _notificationsRef.doc(lastNotificationId).get();

      if (!lastNotificationDoc.exists) return [];

      querySnapshot = await _notificationsRef
          .where(NotifFields.targetId, isEqualTo: userId)
          .orderBy(NotifFields.postId, descending: true)
          .startAfterDocument(lastNotificationDoc)
          .limit(10)
          .get();
    }

    for (var doc in querySnapshot.docs) {
      Notif notification = Notif.fromJSON(doc.data() as Map<String, dynamic>);

      notifications.add(notification);
    }

    return notifications;
  }
}
