import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/helpers/log_climb_navigation.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroBottomButtons extends StatelessWidget {
  final Munro munro;
  final bool isBagged;
  const MunroBottomButtons({super.key, required this.munro, required this.isBagged});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: CtaButton(
            onPressed: () => navigateToLogClimb(context: context, munro: munro),
            child: Text(isBagged ? 'Log Another Climb' : 'Log A Climb'),
          ),
        ),
        PrimaryIconButton(
          analyticsEvent: AnalyticsEvent.walkHighlandsMunroLinkClicked,
          analyticsProperties: {
            AnalyticsProp.munroId: munro.id,
            AnalyticsProp.munroName: munro.name,
          },
          onPressed: () async {
            try {
              await launchUrl(
                Uri.parse(munro.link),
              );
            } on Exception catch (error, stackTrace) {
              context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
              Clipboard.setData(ClipboardData(text: munro.link));
              showSnackBar(context, 'Copied link. Go to browser to open.');
            }
          },
          icon: Icon(PhosphorIconsRegular.arrowSquareOut),
        ),
        PrimaryIconButton(
          analyticsEvent: AnalyticsEvent.munroStartingPointClicked,
          analyticsProperties: {
            AnalyticsProp.munroId: munro.id,
            AnalyticsProp.munroName: munro.name,
          },
          onPressed: () async {
            try {
              await launchUrl(
                Uri.parse(munro.startingPointURL),
              );
            } on Exception catch (error, stackTrace) {
              context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
              Clipboard.setData(ClipboardData(text: munro.startingPointURL));
              showSnackBar(context, 'Copied link. Go to browser to open.');
            }
          },
          icon: Icon(PhosphorIconsRegular.mapPin),
        ),
      ],
    );
  }
}
