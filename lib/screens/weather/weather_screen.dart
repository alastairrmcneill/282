import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/weather_model.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/weather/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';

class WeatherScreen extends StatefulWidget {
  static const String route = "/weather";
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final weatherState = context.watch<WeatherState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${munroState.selectedMunro?.name ?? ""} weather'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weatherState.forecast.map((Weather weather) {
                  final index = weatherState.forecast.indexOf(weather);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        _pageController.animateToPage(index,
                            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          weather.date.dayOfWeekLetter(),
                          style: Theme.of(context).textTheme.bodyMedium!,
                        ),
                        const SizedBox(height: 5),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selectedIndex == index ? MyColors.accentColor : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            weather.date.day.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: selectedIndex == index ? Colors.white : Colors.black, height: 1.2),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 400,
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
              ),
              const WeatherDisclaimer(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
