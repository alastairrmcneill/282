// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/user_database.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class PushNotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future initNotifications(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);

    NotificationSettings result = await _messaging.requestPermission();

    if (result.authorizationStatus == AuthorizationStatus.authorized) {
      final String? token = await _messaging.getToken();
      if (userState.currentUser != null) {
        AppUser appUser = userState.currentUser!;
        AppUser newAppUser = appUser.copyWith(fcmToken: token);

        UserDatabase.update(context, appUser: newAppUser);
      }
    }

    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotificaiton);
    initPushNotificaitons();
  }

  static Future initPushNotificaitons() async {
    await _messaging.getInitialMessage().then(handleBackgroundNotificaiton);

    FirebaseMessaging.onMessageOpenedApp.listen(handleBackgroundNotificaiton);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotificaiton);
  }

  static Future<void> handleBackgroundNotificaiton(RemoteMessage? message) async {
    print("Message: ${message.toString()}");
    if (message == null) return;

    print(navigatorKey.currentState);

    navigatorKey.currentState?.pushNamed("/feed_tab");
  }
}
