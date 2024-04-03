import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class WeatherState extends ChangeNotifier {
  WeatherStatus _status = WeatherStatus.initial;
  Error _error = Error();
  List<Weather> _forecast = [];

  WeatherStatus get status => _status;
  Error get error => _error;
  List<Weather> get forecast => _forecast;

  set setForecast(List<Weather> forecast) {
    _forecast = forecast;
    notifyListeners();
  }

  set setStatus(WeatherStatus weatherStatus) {
    _status = weatherStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = WeatherStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum WeatherStatus { initial, loading, loaded, error }
