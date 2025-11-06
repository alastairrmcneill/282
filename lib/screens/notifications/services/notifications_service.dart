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

      List<String> blockedUsers = userState.blockedUsers;

      // Read comments for post
      notificationsState.setNotifications = await NotificationsDatabase.readUserNotifs(
        context,
        userId: userState.currentUser?.uid ?? "",
        excludedSourceIds: blockedUsers,
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

      List<String> blockedUsers = userState.blockedUsers;

      // Add posts from database
      notificationsState.addNotifications = await NotificationsDatabase.readUserNotifs(
        context,
        userId: userState.currentUser?.uid ?? "",
        excludedSourceIds: blockedUsers,
        offset: notificationsState.notifications.length,
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
