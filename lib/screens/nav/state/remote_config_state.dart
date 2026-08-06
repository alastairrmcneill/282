import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';

class RemoteConfigState extends ChangeNotifier {
  final RemoteConfigRespository _remoteConfigRepository;
  final Logger _logger;

  RemoteConfigState(
    this._remoteConfigRepository,
    this._logger,
  );

  RemoteConfigStatus _status = RemoteConfigStatus.initial;
  Error _error = Error();
  RemoteConfig _config = RemoteConfig.defaultConfig;

  RemoteConfigStatus get status => _status;
  Error get error => _error;
  RemoteConfig get config => _config;

  Future<void> init() async {
    _status = RemoteConfigStatus.loading;
    notifyListeners();

    try {
      await _remoteConfigRepository.init();
      _config = _readConfigSnapshot();
      _status = RemoteConfigStatus.loaded;
    } catch (error, stackTrace) {
      _error = Error(message: error.toString());
      // Not reported as an error: fetching remote config can time out on a slow
      // cold-start connection, but we always fall back to the built-in defaults
      // below and nothing in the UI branches on RemoteConfigStatus.error, so this
      // never actually degrades the app. Logging it as info keeps it visible as
      // context on any other error in the session without paging anyone for a
      // condition that already fully recovered.
      _logger.info('Failed to initialize remote config, falling back to defaults: $error', context: {
        'stackTrace': stackTrace.toString(),
      });
      _config = _readConfigSnapshot();
      _status = RemoteConfigStatus.error;
    } finally {
      notifyListeners();
    }
  }

  RemoteConfig _readConfigSnapshot() {
    return RemoteConfig(
      feedbackSurveyNumber: _remoteConfigRepository.getInt(RCFields.feedbackSurveyNumber),
      latestAppVersion: _remoteConfigRepository.getString(RCFields.latestAppVersion),
      hardUpdateBuildNumber: _remoteConfigRepository.getInt(RCFields.hardUpdateBuildNumber),
      whatsNew: _remoteConfigRepository.getString(RCFields.whatsNew),
      groupFilterNewIcon: _remoteConfigRepository.getBool(RCFields.groupFilterNewIcon),
    );
  }
}

enum RemoteConfigStatus { initial, loading, loaded, error }
