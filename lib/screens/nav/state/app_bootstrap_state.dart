import 'package:flutter/material.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/screens/nav/state/startup_overlay_policies.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class AppBootstrapState extends ChangeNotifier {
  final RemoteConfigState _remoteConfig;
  final DeepLinkState _deepLinkState;
  final SettingsState _settingsState;
  final AuthState _authState;
  final UserState _userState;
  final MunroState _munroState;
  final MunroCompletionState _munroCompletionState;
  final SavedListState _savedListState;
  final PushNotificationState _pushNotificationState;
  final StartupOverlayPolicies _startupOverlayPolicies;
  final FlavorState _flavorState;
  final Logger _logger;

  AppBootstrapState(
    this._remoteConfig,
    this._deepLinkState,
    this._settingsState,
    this._authState,
    this._userState,
    this._munroState,
    this._munroCompletionState,
    this._savedListState,
    this._pushNotificationState,
    this._startupOverlayPolicies,
    this._flavorState,
    this._logger,
  );

  AppBootstrapStatus _status = AppBootstrapStatus.initial;
  AppBootstrapStatus get status => _status;

  Object? _error;
  Object? get error => _error;

  bool get isReady => _status == AppBootstrapStatus.ready;

  bool _started = false;

  Future<void> init() async {
    if (_started) return;
    _started = true;

    _status = AppBootstrapStatus.loading;
    notifyListeners();

    try {
      await Future.wait([
        _remoteConfig.init(),
        _settingsState.load(),
        _munroState.loadMunros(),
        _deepLinkState.init(enableLogging: _flavorState.environment != AppEnvironment.prod),
        _pushNotificationState.init(),
      ]);

      final uid = _authState.currentUserId;

      if (uid != null) {
        await _userState.readUser(uid: uid);
        await _munroCompletionState.loadUserMunroCompletions();
        await _savedListState.readUserSavedLists();
        await _userState.loadBlockedUsers();
        await _pushNotificationState.syncTokenIfNeeded();
      }

      _status = AppBootstrapStatus.ready;
      _error = null;
      notifyListeners();

      _startupOverlayPolicies.maybeEnqueueHardUpdate();
      _startupOverlayPolicies.maybeEnqueueSoftUpdate();
      _startupOverlayPolicies.maybeEnqueueWhatsNew();
      _startupOverlayPolicies.maybeEnqueueAppSurvey();
    } catch (error, stacktrace) {
      _logger.error('Startup init failed', error: error, stackTrace: stacktrace);
      _status = AppBootstrapStatus.error;
      _error = error;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    _started = false;
    await init();
  }
}

enum AppBootstrapStatus { initial, loading, ready, error }
