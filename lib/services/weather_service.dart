import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:http/http.dart' as http;
import 'package:two_eight_two/services/services.dart';

class WeatherService {
  static Future getWeather(BuildContext context) async {
    // Create notifier
    SettingsState settingsState = Provider.of<SettingsState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    WeatherState weatherState = Provider.of<WeatherState>(context, listen: false);

    List<Weather> forecast = [];

    try {
      if (munroState.selectedMunro == null) return;

      weatherState.setStatus = WeatherStatus.loading;

      double lat = munroState.selectedMunro!.lat;
      double long = munroState.selectedMunro!.lng;
      String metric = settingsState.metricTemperature ? 'metric' : 'imperial';

      String url =
          'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$long&exclude=minutely,hourly,alerts&appid=${dotenv.env['WEATHER_API_KEY']}&units=$metric';

      // Make the request
      var response = await http.get(Uri.parse(url));

      // Check the status code before decoding the response
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Use the data
        List<dynamic> forecastJson = data[WeatherFields.daily];

        for (var json in forecastJson) {
          forecast.add(Weather.fromJsonDay(json));
        }

        weatherState.setForecast = forecast;
        weatherState.setStatus = WeatherStatus.loaded;
      } else {
        // Log the error
        Log.error("Error fetching weather data: ${jsonDecode(response.body)}");
        weatherState.setError = Error(
          code: jsonDecode(response.body),
          message: "There was an error fetching the weather data.",
        );

        // Return an empty list
        weatherState.setForecast = forecast;
      }
    } on Exception catch (error, stackTrace) {
      weatherState.setError = Error(
        code: error.toString(),
        message: "There was an error fetching the weather data.",
      );
      Log.error(error.toString(), stackTrace: stackTrace);
    }
  }
}
