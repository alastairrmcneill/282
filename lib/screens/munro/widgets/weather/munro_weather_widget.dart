import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/weather/weather_forecast_page.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroWeatherWidget extends StatefulWidget {
  final Munro munro;
  const MunroWeatherWidget({super.key, required this.munro});

  @override
  State<MunroWeatherWidget> createState() => _MunroWeatherWidgetState();
}

class _MunroWeatherWidgetState extends State<MunroWeatherWidget> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch weather data and update the Provider after the widget has been built
      context.read<WeatherState>().getWeather(widget.munro);
    });
  }

  Widget _buildLoadingScreen() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Weather',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            7,
            (_) => Expanded(
              child: ShimmerBox(width: double.infinity, height: 60, borderRadius: 10),
            ),
          ),
        ),
        const SizedBox(height: 15),
        ShimmerBox(width: 100, height: 100, borderRadius: 10),
      ],
    );
  }

  Widget _buildErrorScreen(String message) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Weather',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 20),
        Icon(PhosphorIconsRegular.warning, size: 50),
        const SizedBox(height: 10),
        Text(
          message,
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }

  Widget _buildScreen(BuildContext context, WeatherState weatherState) {
    final forecast = weatherState.forecast.sublist(0, 7);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Weather',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: forecast.map((Weather weather) {
            final index = forecast.indexOf(weather);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                    _pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedIndex == index ? context.colors.accent : Colors.transparent,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Column(
                      children: [
                        Text(
                          weather.date.dayOfWeekShort(),
                          style: Theme.of(context).textTheme.labelLarge!,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          weather.date.day.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: context.colors.textMuted),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            "assets/weather/${weather.icon}.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            itemCount: weatherState.forecast.length,
            itemBuilder: (context, index) {
              final Weather weather = weatherState.forecast[index];
              return WeatherForecastPage(weather: weather);
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherState>(
      builder: (context, weatherState, child) {
        switch (weatherState.status) {
          case WeatherStatus.loading:
            return _buildLoadingScreen();
          case WeatherStatus.error:
            return _buildErrorScreen(weatherState.error.message);
          case WeatherStatus.loaded:
            return _buildScreen(context, weatherState);
          default:
            return _buildLoadingScreen();
        }
      },
    );
  }
}
