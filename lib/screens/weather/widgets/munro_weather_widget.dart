import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
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
          case WeatherStatus.initial:
            return const ShimmerBox(width: double.infinity, height: 200, borderRadius: 10);
          case SearchStatus.loading:
            return const ShimmerBox(width: double.infinity, height: 200, borderRadius: 10);
          case SearchStatus.error:
            return CenterText(text: weatherState.error.message);
          default:
            return _buildScreen(
              context,
              weatherState: weatherState,
            );
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, {required WeatherState weatherState}) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[200]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "7 Day Weather Forecast",
            style: Theme.of(context).textTheme.headline6,
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: weatherState.forecast.length,
              itemBuilder: (context, index) {
                Weather weather = weatherState.forecast[index];
                return ListTile(
                  title: Text(weather.date.toString()),
                  subtitle: Text(weather.description),
                  trailing: Text("${weather.temperature}°"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
