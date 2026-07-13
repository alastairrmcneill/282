import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/weather/weather_item_tile.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class WeatherForecastPage extends StatelessWidget {
  final Weather weather;
  const WeatherForecastPage({super.key, required this.weather});
  @override
  Widget build(BuildContext context) {
    final settingsState = context.read<SettingsState>();
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: Image.asset(
                  "assets/weather/${weather.icon}.png",
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 5),
              Text(weather.description, style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${weather.temperatureMax.round()}°',
                style: Theme.of(context).textTheme.displayLarge!,
              ),
              const SizedBox(width: 5),
              Text(
                '${weather.temperatureMin.round()}°',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: context.colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              WeatherItemTile(
                iconData: PhosphorIconsRegular.wind,
                value: '${weather.windSpeed.round()} ${settingsState.metricTemperature ? 'km/h' : 'mph'}',
              ),
              WeatherItemTile(
                iconData: PhosphorIconsRegular.drop,
                value: '${(weather.rain * 100).round()}%',
              ),
              WeatherItemTile(
                iconData: CupertinoIcons.sunrise,
                value: DateFormat('hh:mm a').format(weather.sunrise).toLowerCase(),
              ),
              WeatherItemTile(
                iconData: CupertinoIcons.sunset,
                value: DateFormat('hh:mm a').format(weather.sunset).toLowerCase(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
