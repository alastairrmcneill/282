import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:two_eight_two/models/models.dart';

class WeartherRepository {
  Future<List<Weather>> fetchWeather(
      {required double lat, required double lon, required String metric, required String apiKey}) async {
    String url =
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,alerts&appid=$apiKey&units=$metric';
    // Make the request
    var response = await http.get(Uri.parse(url));

    // Check the status code before decoding the response
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // Use the data
      List<dynamic> forecastJson = data[WeatherFields.daily];

      return forecastJson.map((json) => Weather.fromJsonDay(json)).toList();
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
