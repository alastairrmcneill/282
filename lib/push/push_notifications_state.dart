import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class PushNotificationState extends ChangeNotifier {
  final PushNotificationRepository _repo;
  final SettingsState _settings;
  final UserState _userState;
  final AppIntentState _intents;
  final Logger _logger;
  PushNotificationState(
    this._repo,
    this._settings,
    this._userState,
    this._intents,
    this._logger,
  );

  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _tokenSub;

  bool _started = false;

  Future<void> init() async {
    if (_started) return;
    _started = true;

    try {
      // Handle cold start.
      final initial = await _repo.getInitialMessage();
      if (initial != null) {
        _intents.enqueue(OpenNotificationsIntent());
      }

      // Handle tap when app in bg/fg.
      _openedSub = _repo.onNotificationOpened.listen((msg) {
        _intents.enqueue(OpenNotificationsIntent());
      });

      // Token refresh lifecycle.
      _tokenSub = _repo.onTokenRefresh.listen((_) async {
        await syncTokenIfNeeded();
      });

      // If push is enabled, try to sync token now (permission gated).
      await syncTokenIfNeeded();
    } catch (e, st) {
      _logger.error('Push init failed', error: e, stackTrace: st);
    }
  }

  Future<bool> onPushSettingChanged() async {
    if (!_settings.enablePushNotifications) {
      return await disablePush();
    } else {
      return await enablePush();
    }
  }

  Future<bool> enablePush() async {
    try {
      final settings = await _repo.requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) return false;

      await syncTokenIfNeeded(force: true);
      return true;
    } catch (e, st) {
      _logger.error('Enable push failed', error: e, stackTrace: st);
      return false;
    }
  }

  Future<bool> disablePush() async {
    try {
      // Optional: remove local FCM token so device stops receiving.
      await _repo.deleteToken();

      // Ensure backend token is cleared.
      final user = _userState.currentUser;
      if (user == null) return true;

      if ((user.fcmToken ?? '').isEmpty) return true;
      await _userState.updateUser(appUser: user.copyWith(fcmToken: ''));
      return true;
    } catch (e, st) {
      _logger.error('Disable push failed', error: e, stackTrace: st);
      return false;
    }
  }

  Future<void> syncTokenIfNeeded({bool force = false}) async {
    // Gate on settings + logged-in user.
    if (!_settings.enablePushNotifications) return;

    final user = _userState.currentUser;
    if (user == null) return;

    try {
      final perm = await _repo.requestPermission();
      if (perm.authorizationStatus != AuthorizationStatus.authorized) return;

      final token = await _repo.getToken();
      if (token == null || token.isEmpty) return;

      if (!force && user.fcmToken == token) return;

      await _userState.updateUser(appUser: user.copyWith(fcmToken: token));
    } catch (e, st) {
      _logger.error('Sync FCM token failed', error: e, stackTrace: st);
    }
  }

  @override
  void dispose() {
    _openedSub?.cancel();
    _tokenSub?.cancel();
    super.dispose();
  }
}
