// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class PushNotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future initNotifications(BuildContext context) async {
    UserState userState = context.read<UserState>();

    NotificationSettings result = await _messaging.requestPermission();

    if (result.authorizationStatus == AuthorizationStatus.authorized) {
      String? token;
      try {
        // On iOS, try to ensure APNS token is available
        if (Platform.isIOS) {
          await _ensureAPNSToken();
        }

        token = await _messaging.getToken();
      } catch (e) {
        print("Error getting FCM token (this is expected if APNS token unavailable): $e");
        // Continue without token - don't interrupt user flow
      }

      if (userState.currentUser != null && token != null) {
        AppUser appUser = userState.currentUser!;
        AppUser newAppUser = appUser.copyWith(fcmToken: token);
        await userState.updateUser(appUser: newAppUser);
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

  static Future<void> _ensureAPNSToken() async {
    // Wait up to 10 seconds for APNS token
    for (int i = 0; i < 20; i++) {
      try {
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          return;
        }
      } catch (e) {
        // Continue waiting
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    // Don't throw exception - let the caller handle it gracefully
    print('APNS token not available after timeout - FCM token retrieval may fail');
  }

  static Future<void> handleBackgroundNotificaiton(RemoteMessage? message) async {
    if (message == null) return;

    navigatorKey.currentState?.pushReplacementNamed(FeedTab.route);
    PostService.getGlobalFeed(navigatorKey.currentContext!);
    final notificationsState = navigatorKey.currentContext?.read<NotificationsState>();
    notificationsState?.getUserNotifications();
    navigatorKey.currentState?.pushNamed(NotificationsScreen.route);
  }

  static Future checkAndUpdateFCMToken(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    SettingsState settingsState = Provider.of<SettingsState>(context, listen: false);

    if (userState.currentUser == null) return;
    if (!settingsState.enablePushNotifications) return;

    NotificationSettings result = await _messaging.requestPermission();
    if (result.authorizationStatus != AuthorizationStatus.authorized) return;

    try {
      // On iOS, try to ensure APNS token is available
      if (Platform.isIOS) {
        await _ensureAPNSToken();
      }

      final String? token = await _messaging.getToken();
      if (token == null) return; // No token available, exit gracefully

      AppUser appUser = userState.currentUser!;
      if (appUser.fcmToken == token) return;

      AppUser newAppUser = appUser.copyWith(fcmToken: token);
      await userState.updateUser(appUser: newAppUser);
    } catch (e) {
      print("Error updating FCM token: $e");
      // Continue without updating token - don't interrupt user flow
    }
  }

  static Future applyFCMToken(BuildContext context) async {
    UserState userState = context.read<UserState>();

    NotificationSettings result = await _messaging.requestPermission();

    if (result.authorizationStatus == AuthorizationStatus.authorized) {
      try {
        // On iOS, try to ensure APNS token is available
        if (Platform.isIOS) {
          await _ensureAPNSToken();
        }

        final String? token = await _messaging.getToken();
        if (userState.currentUser != null && token != null) {
          AppUser appUser = userState.currentUser!;
          AppUser newAppUser = appUser.copyWith(fcmToken: token);
          await userState.updateUser(appUser: newAppUser);
        }
      } catch (e) {
        print("Error applying FCM token: $e");
        // Continue without token - don't interrupt user flow
      }
    }
  }

  static Future removeFCMToken(BuildContext context) async {
    UserState userState = context.read<UserState>();

    if (userState.currentUser != null) {
      AppUser appUser = userState.currentUser!;
      if (appUser.fcmToken != null) {
        AppUser newAppUser = appUser.copyWith(fcmToken: "");
        await userState.updateUser(appUser: newAppUser);
      }
    }
  }
}
