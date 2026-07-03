import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationRepository {
  PushNotificationRepository(this._messaging);

  final FirebaseMessaging _messaging;

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onNotificationOpened =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission();
  }

  Future<NotificationSettings> getNotificationSettings() {
    return _messaging.getNotificationSettings();
  }

  Future<String?> getToken() async {
    if (Platform.isIOS) {
      final apnsReady = await _ensureApnsToken();
      if (!apnsReady) return null;
    }
    return _messaging.getToken();
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }

  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  Future<bool> _ensureApnsToken() async {
    for (int i = 0; i < 20; i++) {
      try {
        final apns = await _messaging.getAPNSToken();
        if (apns != null) return true;
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }
}
