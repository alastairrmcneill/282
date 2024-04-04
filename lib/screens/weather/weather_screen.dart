import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/weather_model.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/weather/widgets/widgets.dart';

class WeatherScreen extends StatefulWidget {
  static const String route = "/weather_screen";
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    WeatherState weatherState = Provider.of<WeatherState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(munroState.selectedMunro?.name ?? ""),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: weatherState.forecast.asMap().entries.map((entry) {
            int index = entry.key;
            Weather weather = entry.value;
            return ExpandableWeatherTile(
              weather: weather,
              isExpanded: index == selectedIndex,
              onTap: () => setState(() => selectedIndex = index),
            );
          }).toList(),
        ),
      ),
    );
  }
}
