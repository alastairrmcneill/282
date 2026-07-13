import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';

class SettingsState extends ChangeNotifier {
  final SettingsRepository _repository;
  final Analytics _analytics;
  final Logger _logger;

  SettingsState(
    this._repository,
    this._analytics,
    this._logger,
  );

  SettingsStatus _status = SettingsStatus.initial;
  Error _error = Error();
  AppSettings? _appSettings = AppSettings.initial;

  SettingsStatus get status => _status;
  Error get error => _error;
  bool get enablePushNotifications => _appSettings?.pushNotifications ?? true;
  bool get metricHeight => _appSettings?.metricHeight ?? false;
  bool get metricTemperature => _appSettings?.metricTemperature ?? true;
  String get defaultPostVisibility => _appSettings?.defaultPostVisibility ?? Privacy.public;
  String get themeModeSetting => _appSettings?.themeMode ?? ThemeModeOption.system;

  set setError(Error error) {
    _status = SettingsStatus.error;
    _error = error;
    notifyListeners();
  }

  Future<void> load() async {
    _status = SettingsStatus.loading;
    notifyListeners();

    try {
      _appSettings = _repository.load();
      _status = SettingsStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue loading the settings.",
      );
    }
  }

  Future<void> update(AppSettings newAppSettings) async {
    _status = SettingsStatus.loading;
    notifyListeners();
    try {
      await _repository.save(newAppSettings);
      _appSettings = newAppSettings;
      _status = SettingsStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue saving the settings.",
      );
    }
  }

  void _trackSettingChanged(String setting, Object value) {
    _analytics.track(
      AnalyticsEvent.settingChanged,
      props: {AnalyticsProp.setting: setting, AnalyticsProp.value: value},
    );
  }

  Future<void> setEnablePushNotifications(bool v) {
    _trackSettingChanged('push_notifications', v);
    return update(_appSettings!.copyWith(pushNotifications: v));
  }

  Future<void> setMetricHeight(bool v) {
    _trackSettingChanged('metric_height', v);
    return update(_appSettings!.copyWith(metricHeight: v));
  }

  Future<void> setMetricTemperature(bool v) {
    _trackSettingChanged('metric_temperature', v);
    return update(_appSettings!.copyWith(metricTemperature: v));
  }

  Future<void> setDefaultPostVisibility(String v) {
    _trackSettingChanged('default_post_visibility', v);
    return update(_appSettings!.copyWith(defaultPostVisibility: v));
  }

  Future<void> setThemeMode(String v) {
    _trackSettingChanged('theme_mode', v);
    return update(_appSettings!.copyWith(themeMode: v));
  }
}

enum SettingsStatus { initial, loading, loaded, error }
