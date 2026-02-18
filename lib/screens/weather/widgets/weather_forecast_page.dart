import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/weather/widgets/widgets.dart';

class WeatherForecastPage extends StatelessWidget {
  final Weather weather;
  const WeatherForecastPage({super.key, required this.weather});

  Widget _buildTemperature(BuildContext context) {
    return RichText(
      textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false),
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '${weather.temperatureMax.round()}°',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.w500, fontSize: 40, height: 0.1),
          ),
          TextSpan(
            text: ' / ${weather.temperatureMin.round()}°',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.read<SettingsState>();
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 30),
          Align(alignment: Alignment.centerLeft, child: _buildTemperature(context)),
          Align(alignment: Alignment.centerLeft, child: Text(weather.date.longDate())),
          const SizedBox(height: 20),
          SizedBox(
            width: 70,
            height: 70,
            child: Image.asset(
              "assets/weather/${weather.icon}.png",
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            weather.summary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              WeatherItemTile(
                iconData: CupertinoIcons.wind,
                value: '${weather.windSpeed.round()} ${settingsState.metricTemperature ? 'km/h' : 'mph'}',
              ),
              WeatherItemTile(
                iconData: CupertinoIcons.drop,
                value: '${(weather.rain * 100).round()}%',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              WeatherItemTile(
                iconData: CupertinoIcons.sunrise,
                value: DateFormat('hh:mm a').format(weather.sunrise),
              ),
              WeatherItemTile(
                iconData: CupertinoIcons.sunset,
                value: DateFormat('hh:mm a').format(weather.sunset),
              ),
            ],
          )
        ],
      ),
    );
  }
}
