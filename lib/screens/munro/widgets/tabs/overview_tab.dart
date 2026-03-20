import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';

class OverviewTab extends StatelessWidget {
  final Munro munro;
  const OverviewTab({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        MunroDescriptionTabs(munro: munro),
        const SizedBox(height: 20),
        OutlineLinkButton(
          icon: PhosphorIconsRegular.mapPin,
          text: 'View starting point',
          link: munro.startingPointURL,
          analyticsEvent: AnalyticsEvent.munroStartingPointClicked,
          analyticsProps: {
            AnalyticsProp.munroId: munro.id,
            AnalyticsProp.munroName: munro.name,
          },
        ),
        const SizedBox(height: 8),
        OutlineLinkButton(
          icon: PhosphorIconsRegular.arrowSquareOut,
          text: 'Open in Walkhighlands',
          link: munro.link,
          analyticsEvent: AnalyticsEvent.walkHighlandsMunroLinkClicked,
          analyticsProps: {
            AnalyticsProp.munroId: munro.id,
            AnalyticsProp.munroName: munro.name,
          },
        ),
        const SizedBox(height: 20),
        MunroCommonlyClimbedWithTabs(munro: munro),
        const SizedBox(height: 90),
      ],
    );
  }
}
