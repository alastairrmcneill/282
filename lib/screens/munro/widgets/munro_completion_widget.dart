import 'package:flutter/material.dart';

class MunroCompletionWidget extends StatelessWidget {
  final int index;
  final DateTime dateTime;
  const MunroCompletionWidget({super.key, required this.index, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text('Summit #$index'),
          Text('Date: $dateTime'),
        ],
      ),
    );
  }
}
