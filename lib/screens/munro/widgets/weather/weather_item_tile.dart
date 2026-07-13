import 'package:flutter/material.dart';

class WeatherItemTile extends StatelessWidget {
  final IconData iconData;
  final String value;
  const WeatherItemTile({super.key, required this.iconData, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          iconData,
          size: 20,
        ),
        const SizedBox(width: 5),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            value,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}
