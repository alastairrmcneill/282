import 'package:flutter/material.dart';

class WeatherItemTile extends StatelessWidget {
  final String emoji;
  final String value;
  final String type;
  const WeatherItemTile({super.key, required this.emoji, required this.value, required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 25),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          type,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w200,
          ),
        ),
      ],
    );
  }
}
