import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class SettingsState extends ChangeNotifier {
  SettingsStatus _status = SettingsStatus.initial;
  Error _error = Error();
  bool _enablePushNotifications = true;
  bool _metricHeight = false;
  bool _metricTemperature = true;

  SettingsStatus get status => _status;
  Error get error => _error;
  bool get enablePushNotifications => _enablePushNotifications;
  bool get metricHeight => _metricHeight;
  bool get metricTemperature => _metricTemperature;

  set setStatus(SettingsStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setMetricHeight(bool metricHeight) {
    _metricHeight = metricHeight;
    notifyListeners();
  }

  set setMetricTemperature(bool metricTemperature) {
    _metricTemperature = metricTemperature;
    notifyListeners();
  }

  set setError(Error error) {
    _status = SettingsStatus.error;
    _error = error;
    notifyListeners();
  }

  set setEnablePushNotifications(bool enablePushNotifications) {
    _enablePushNotifications = enablePushNotifications;
    notifyListeners();
  }
}

enum SettingsStatus { initial, loading, loaded, error }
