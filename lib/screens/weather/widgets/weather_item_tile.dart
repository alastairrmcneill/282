import 'package:flutter/material.dart';

class WeatherItemTile extends StatelessWidget {
  final IconData iconData;
  final String value;
  const WeatherItemTile({super.key, required this.iconData, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(iconData),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
