import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/explore/screens/screens.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class ExploreHeaderFilterButton extends StatelessWidget {
  const ExploreHeaderFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(PhosphorIconsRegular.funnel, color: context.colors.accent, size: 18),
            onPressed: () {
              context.read<Analytics>().track(AnalyticsEvent.exploreFilterButtonTapped);
              Navigator.of(context).pushNamed(FilterScreen.route);
            },
          ),
          if (munroState.isFilterOptionsSet)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.colors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
