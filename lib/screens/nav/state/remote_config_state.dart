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
      _logger.error('Failed to initialize remote config: $error', stackTrace: stackTrace);
      _config = _readConfigSnapshot();
      _status = RemoteConfigStatus.error;
    } finally {
      print("🎯 ~ RemoteConfigState ~ init ~ _config: $_config");
      notifyListeners();
    }
  }

  RemoteConfig _readConfigSnapshot() {
    return RemoteConfig(
      feedbackSurveyNumber: _remoteConfigRepository.getInt(RCFields.feedbackSurveyNumber),
      latestAppVersion: _remoteConfigRepository.getString(RCFields.latestAppVersion),
      hardUpdateBuildNumber: _remoteConfigRepository.getInt(RCFields.hardUpdateBuildNumber),
      whatsNew: _remoteConfigRepository.getString(RCFields.whatsNew),
      showPrivacyOption: _remoteConfigRepository.getBool(RCFields.showPrivacyOption),
      groupFilterNewIcon: _remoteConfigRepository.getBool(RCFields.groupFilterNewIcon),
      mapboxMapScreen: _remoteConfigRepository.getBool(RCFields.mapboxMapScreen),
    );
  }
}

enum RemoteConfigStatus { initial, loading, loaded, error }
