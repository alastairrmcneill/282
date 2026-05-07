import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';

class OverviewTab extends StatelessWidget {
  final Munro munro;
  const OverviewTab({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          const SizedBox(height: 15),
          MunroDescription(munro: munro),
          const SizedBox(height: 30),
          MunroMapWidget(munro: munro, showExpandButton: true),
          const SizedBox(height: 30),
          MunroWeatherWidget(munro: munro),
          SizedBox(height: munro.commonlyClimbedWith.isEmpty ? 0 : 30),
          MunrosCommonlyClimbedWithGrid(munro: munro),
          SizedBox(height: munro.commonlyClimbedWith.isEmpty ? 0 : 10),
        ],
      ),
    );
  }
}
