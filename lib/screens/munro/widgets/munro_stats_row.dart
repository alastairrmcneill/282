import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroStatsRow extends StatelessWidget {
  const MunroStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    SettingsState settingsState = Provider.of<SettingsState>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatText(
            text: "Height",
            stat: settingsState.metricHeight
                ? "${munroState.selectedMunro?.meters}"
                : "${munroState.selectedMunro?.feet}",
            subStat: settingsState.metricHeight ? "m" : "ft",
          ),
          StatText(text: "Area", stat: munroState.selectedMunro?.area ?? ""),
          StatText(
            text: "Rating",
            stat: munroState.selectedMunro?.averageRating?.toStringAsFixed(1) ?? "0",
            subStat: "/5",
          ),
        ],
      ),
    );
  }
}
