import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroStatsRow extends StatelessWidget {
  final VoidCallback? onAreaTap;
  final VoidCallback? onReviewsTap;
  const MunroStatsRow({super.key, this.onAreaTap, this.onReviewsTap});

  @override
  Widget build(BuildContext context) {
    final munroDetailState = context.watch<MunroDetailState>();
    final settingsState = context.read<SettingsState>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatText(
            text: "Height",
            stat: settingsState.metricHeight
                ? "${munroDetailState.selectedMunro?.meters}"
                : "${munroDetailState.selectedMunro?.feet}",
            subStat: settingsState.metricHeight ? "m" : "ft",
          ),
          StatText(
            onTap: onAreaTap ??
                () {
                  Navigator.of(context).pushNamed(
                    MunroAreaScreen.route,
                    arguments: MunroAreaScreenArgs(
                      area: munroDetailState.selectedMunro?.area ?? "",
                    ),
                  );
                },
            text: "Area",
            stat: munroDetailState.selectedMunro?.area ?? "",
          ),
          StatText(
            onTap: onReviewsTap,
            text: "Rating",
            stat: munroDetailState.selectedMunro?.averageRating?.toStringAsFixed(1) ?? "0",
            subStat: "/5",
          ),
        ],
      ),
    );
  }
}
