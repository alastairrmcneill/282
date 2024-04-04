import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/weather/widgets/widgets.dart';

class ExpandableWeatherTile extends StatelessWidget {
  final Weather weather;
  final bool isExpanded;
  final Function() onTap;
  const ExpandableWeatherTile({super.key, required this.weather, required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(child: child, opacity: animation);
        },
        child: isExpanded
            ? ExpandedWeatherTile(key: ValueKey('expanded'), weather: weather)
            : CollapsedWeatherTile(key: ValueKey('collapsed'), weather: weather),
      ),
    );
  }
}
