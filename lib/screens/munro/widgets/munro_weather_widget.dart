import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/weather/weather_screen.dart';
import 'package:two_eight_two/services/weather_service.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class MunroWeatherWidget extends StatefulWidget {
  const MunroWeatherWidget({super.key});

  @override
  State<MunroWeatherWidget> createState() => _MunroWeatherWidgetState();
}

class _MunroWeatherWidgetState extends State<MunroWeatherWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch weather data and update the Provider after the widget has been built
      WeatherService.getWeather(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherState>(
      builder: (context, weatherState, child) {
        switch (weatherState.status) {
          case WeatherStatus.loaded:
            return _buildScreen(
              context,
              weatherState: weatherState,
            );
          case WeatherStatus.loading:
            return const ShimmerBox(width: double.infinity, height: 200, borderRadius: 10);
          case WeatherStatus.error:
            return CenterText(text: weatherState.error.message);
          default:
            return const ShimmerBox(width: double.infinity, height: 200, borderRadius: 10);
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, {required WeatherState weatherState}) {
    SettingsState settingsState = Provider.of<SettingsState>(context, listen: false);
    Weather weather = weatherState.forecast[0];
    return InkWell(
      onTap: () => Navigator.pushNamed(context, WeatherScreen.route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weather Prediction",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            DateFormat('EEE, d MMMM yyyy').format(weather.date),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w300),
          ),
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color.fromRGBO(231, 240, 226, 1), Color.fromRGBO(250, 255, 249, 1)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Image.asset(
                          "assets/weather/${weather.icon}.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${weather.temperature.round()}°${settingsState.metricTemperature ? 'C' : 'F'}',
                                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 28,
                                          ),
                                    ),
                                    Text(
                                      weather.description,
                                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 16,
                                          ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.drop,
                            size: 18,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            ' ${(weather.rain * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.sunrise,
                            size: 18,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            DateFormat('hh:mm a').format(weather.sunrise),
                            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.sunset,
                            size: 18,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            DateFormat('hh:mm a').format(weather.sunset),
                            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
