import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/weather/widgets/widgets.dart';

class ExpandedWeatherTile extends StatelessWidget {
  final Weather weather;
  const ExpandedWeatherTile({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    SettingsState settingsState = Provider.of<SettingsState>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                '${weather.temperature.round()}°${settingsState.metricTemperature ? 'C' : 'F'}',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/weather/${weather.icon}.png'),
            ),
            Text(
              weather.summary,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      WeatherItemTile(
                        emoji: '💨',
                        value: '${weather.windSpeed.round()} ${settingsState.metricTemperature ? 'km/h' : 'mph'}',
                        type: 'Wind',
                      ),
                      WeatherItemTile(
                        emoji: '💦',
                        value: '${weather.humidity}%',
                        type: 'Humidity',
                      ),
                      WeatherItemTile(
                        emoji: '☔️',
                        value: '${(weather.rain * 100).round()}%',
                        type: 'Rain',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
