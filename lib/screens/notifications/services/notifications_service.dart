// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class NotificationsService {
  static Future getUserNotifications(BuildContext context) async {
    NotificationsState notificationsState = Provider.of<NotificationsState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      // Set Status
      notificationsState.setStatus = NotificationsStatus.loading;

      // Read comments for post
      notificationsState.setNotifications = await NotificationsDatabase.readUserNotifs(
        context,
        userId: userState.currentUser?.uid ?? "",
        lastNotificationId: null,
      );

      // Update status
      notificationsState.setStatus = NotificationsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      notificationsState.setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving your notifications. Please try again.",
      );
    }
  }

  static Future paginateUserNotifications(BuildContext context) async {
    NotificationsState notificationsState = Provider.of<NotificationsState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      notificationsState.setStatus = NotificationsStatus.paginating;

      // Find last user ID
      String? lastNotificationId;
      if (notificationsState.notifications.isNotEmpty) {
        lastNotificationId = notificationsState.notifications.last.uid;
      }

      // Add posts from database
      notificationsState.addNotifications = await NotificationsDatabase.readUserNotifs(
        context,
        userId: userState.currentUser?.uid ?? "",
        lastNotificationId: lastNotificationId,
      );

      notificationsState.setStatus = NotificationsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      notificationsState.setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving your notifications. Please try again.",
      );
    }
  }

  static Future markNotificationAsRead(BuildContext context, {required Notif notification}) async {
    NotificationsState notificationsState = Provider.of<NotificationsState>(context, listen: false);

    try {
      Notif newNotification = notification.copyWith(read: true);

      NotificationsDatabase.updateNotif(context, notification: newNotification);
      notificationsState.markNotificationAsRead(notification);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      notificationsState.setError = Error(
        code: error.toString(),
        message: "There was an issue marking your notification as done. Please try again.",
      );
    }
  }

  static Future markAllNotificationsAsRead(BuildContext context) async {
    NotificationsState notificationsState = Provider.of<NotificationsState>(context, listen: false);

    try {
      for (Notif notification in notificationsState.notifications) {
        if (notification.read) {
          continue;
        }
        Notif newNotification = notification.copyWith(read: true);
        await NotificationsDatabase.updateNotif(context, notification: newNotification);
        notificationsState.markNotificationAsRead(newNotification);
      }
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      notificationsState.setError = Error(
        code: error.toString(),
        message: "There was an issue marking your notifications as done. Please try again.",
      );
    }
  }
}
