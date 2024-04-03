import 'package:two_eight_two/extensions/extensions.dart';

class Weather {
  final DateTime date;
  final String summary;
  final double temperature;
  final double windSpeed;
  final int humidity;
  final String description;
  final double rain;
  final String icon;

  Weather({
    required this.date,
    required this.summary,
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.description,
    required this.rain,
    required this.icon,
  });

  static Weather fromJsonDay(Map<String, dynamic> json) {
    int dt = json[WeatherFields.dt];
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
    String summary = json[WeatherFields.summary];
    String icon = json[WeatherFields.weather][0][WeatherFields.icon];
    num temperature = json[WeatherFields.temp][WeatherFields.day];
    num windGust = json[WeatherFields.windGust];
    num humidity = json[WeatherFields.humidity];
    num pop = json[WeatherFields.pop];
    String description = json[WeatherFields.weather][0][WeatherFields.description];

    return Weather(
      date: date,
      summary: summary,
      temperature: temperature.toDouble(),
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
              ${WeatherFields.summary}: $summary, 
              ${WeatherFields.temp}: $temperature, 
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
  static const String summary = 'summary';
  static const String daily = 'daily';
  static const String temp = 'temp';
  static const String day = 'day';
  static const String windGust = 'wind_gust';
  static const String humidity = 'humidity';
  static const String weather = 'weather';
  static const String icon = 'icon';
  static const String pop = 'pop';
  static const String description = 'description';
}
