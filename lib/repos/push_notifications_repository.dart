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
    try {
      return await _messaging.getToken();
    } catch (e) {
      // On Android, a device can accumulate too many stale FCM registrations
      // for its Instance ID, and every getToken() call fails with
      // TOO_MANY_REGISTRATIONS until it's cleared. Deleting the local
      // Instance ID and requesting a fresh token resolves it — see
      // https://github.com/firebase/firebase-android-sdk/issues/2438
      if (e.toString().contains('TOO_MANY_REGISTRATIONS')) {
        await deleteToken();
        return await _messaging.getToken();
      }
      rethrow;
    }
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
