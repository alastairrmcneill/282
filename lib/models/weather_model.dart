import 'package:two_eight_two/extensions/extensions.dart';

class Weather {
  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;
  final String summary;
  final double temperature;
  final double temperatureMin;
  final double temperatureMax;
  final double windSpeed;
  final int humidity;
  final String description;
  final double rain;
  final String icon;

  Weather({
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.summary,
    required this.temperature,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.windSpeed,
    required this.humidity,
    required this.description,
    required this.rain,
    required this.icon,
  });

  static Weather fromJsonDay(Map<String, dynamic> json) {
    int dt = json[WeatherFields.dt];
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
    int sunriseRaw = json[WeatherFields.sunrise];
    DateTime sunrise = DateTime.fromMillisecondsSinceEpoch(sunriseRaw * 1000);
    int sunsetRaw = json[WeatherFields.sunset];
    DateTime sunset = DateTime.fromMillisecondsSinceEpoch(sunsetRaw * 1000);
    String summary = json[WeatherFields.summary];
    String icon = json[WeatherFields.weather][0][WeatherFields.icon];
    num temperature = json[WeatherFields.temp][WeatherFields.day];
    num temperatureMin = json[WeatherFields.temp][WeatherFields.min];
    num temperatureMax = json[WeatherFields.temp][WeatherFields.max];
    num windGust = json[WeatherFields.windGust];
    num humidity = json[WeatherFields.humidity];
    num pop = json[WeatherFields.pop];
    String description = json[WeatherFields.weather][0][WeatherFields.description];

    return Weather(
      date: date,
      sunrise: sunrise,
      sunset: sunset,
      summary: summary,
      temperature: temperature.toDouble(),
      temperatureMin: temperatureMin.toDouble(),
      temperatureMax: temperatureMax.toDouble(),
      windSpeed: windGust.toDouble(),
      humidity: humidity.toInt(),
      description: description.capitalize(),
      icon: icon,
      rain: pop.toDouble(),
    );
  }

  @override
  String toString() {
    return """Weather:
              ${WeatherFields.dt}: $date,
              ${WeatherFields.sunrise}: $sunrise,
              ${WeatherFields.sunset}: $sunset,
              ${WeatherFields.summary}: $summary, 
              ${WeatherFields.temp}: $temperature,
              ${WeatherFields.min}: $temperatureMin,
              ${WeatherFields.max}: $temperatureMax, 
              ${WeatherFields.windGust}: $windSpeed, 
              ${WeatherFields.humidity}: $humidity, 
              ${WeatherFields.description}: $description, 
              ${WeatherFields.icon}: $icon,
              ${WeatherFields.pop}: $rain,
              """;
  }
}

class WeatherFields {
  static const String dt = 'dt';
  static const String sunrise = 'sunrise';
  static const String sunset = 'sunset';
  static const String summary = 'summary';
  static const String daily = 'daily';
  static const String temp = 'temp';
  static const String day = 'day';
  static const String min = 'min';
  static const String max = 'max';
  static const String windGust = 'wind_gust';
  static const String humidity = 'humidity';
  static const String weather = 'weather';
  static const String icon = 'icon';
  static const String pop = 'pop';
  static const String description = 'description';
}
