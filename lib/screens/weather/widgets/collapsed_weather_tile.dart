import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class CollapsedWeatherTile extends StatelessWidget {
  final Weather weather;
  const CollapsedWeatherTile({super.key, required this.weather});

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
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  weather.date.dayOfWeek(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              Text(
                '${weather.temperature.round()}°${settingsState.metricTemperature ? 'C' : 'F'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    Image.asset(
                      'assets/weather/${weather.icon}.png',
                      width: 40,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
