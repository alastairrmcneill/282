import 'package:flutter/material.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class WeatherState extends ChangeNotifier {
  final WeartherRepository _weatherRepository;
  final SettingsState settingsState;
  final MunroState munroState;
  final Logger _logger;

  WeatherState(
    this._weatherRepository,
    this.settingsState,
    this.munroState,
    this._logger,
  );

  WeatherStatus _status = WeatherStatus.initial;
  Error _error = Error();
  List<Weather> _forecast = [];

  WeatherStatus get status => _status;
  Error get error => _error;
  List<Weather> get forecast => _forecast;

  Future getWeather() async {
    try {
      if (munroState.selectedMunro == null) return;

      setStatus = WeatherStatus.loading;

      double lat = munroState.selectedMunro!.lat;
      double long = munroState.selectedMunro!.lng;
      String metric = settingsState.metricTemperature ? 'metric' : 'imperial';
      String apiKey = AppConfig.fromEnvironment().weatherApiKey;
      var response = await _weatherRepository.fetchWeather(lat: lat, lon: long, metric: metric, apiKey: apiKey);

      _forecast = response;
      setStatus = WeatherStatus.loaded;
    } catch (error, stackTrace) {
      setError = Error(
        code: error.toString(),
        message: "There was an error fetching the weather data.",
      );
      _logger.error(error.toString(), stackTrace: stackTrace);
    }
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
