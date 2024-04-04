import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/weather/weather_screen.dart';
import 'package:two_eight_two/services/weather_service.dart';
import 'package:two_eight_two/widgets/widgets.dart';

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
    return InkWell(
      onTap: () => Navigator.pushNamed(context, WeatherScreen.route),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 141, 225, 214), Color.fromARGB(255, 175, 212, 246)],
          ),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              width: (MediaQuery.of(context).size.width - 40) / 3,
              height: 100,
              child: Image.asset(
                "assets/weather/${weatherState.forecast[0].icon}.png",
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${weatherState.forecast[0].temperature.round()}°${settingsState.metricTemperature ? 'C' : 'F'}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Temp',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${(weatherState.forecast[0].rain * 100).round()}%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Precipitation',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: weatherState.forecast
                        .sublist(1, 4)
                        .map(
                          (Weather forecastDay) => Container(
                            width: (MediaQuery.of(context).size.width - 240) / 3,
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  forecastDay.date.dayOfWeekShort(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                                Image.asset(
                                  "assets/weather/${forecastDay.icon}.png",
                                  fit: BoxFit.cover,
                                  width: 30,
                                  height: 30,
                                ),
                                Text(
                                  '${forecastDay.temperature.round()}°${settingsState.metricTemperature ? 'C' : 'F'}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
