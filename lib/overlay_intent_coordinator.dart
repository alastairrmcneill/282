import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class OverlayIntentCoordinator extends StatelessWidget {
  const OverlayIntentCoordinator({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final next = context.watch<OverlayIntentState>().next;

    if (next != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final intent = context.read<OverlayIntentState>().consumeNext();
        if (intent == null) return;

        await _handleIntent(context, intent);
      });
    }

    return child;
  }

  Future<void> _handleIntent(BuildContext context, OverlayIntent intent) async {
    final navState = navigatorKey.currentState;
    final navCtx = navState?.overlay?.context;

    if (navCtx == null) return;

    switch (intent) {
      case HardUpdateDialogIntent():
        navCtx.read<Analytics>().track(AnalyticsEvent.hardAppUpdateDialogShown);
        showDialog(
          context: navCtx,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return HardUpdateDialog();
          },
        );
        return;
      case SoftUpdateDialogIntent():
        navCtx.read<Analytics>().track(AnalyticsEvent.appUpdateDialogShown);

        showDialog(
          context: navCtx,
          builder: (BuildContext context) {
            return SoftUpdateDialog(
              currentVersion: intent.currentVersion,
              latestVersion: intent.latestVersion,
              whatsNew: intent.whatsNew,
            );
          },
        ).then(
          (_) => navCtx
              .read<AppFlagsRepository>()
              .setLastAppUpdateDialogDate(DateFormat("dd/MM/yyyy").format(DateTime.now())),
        );
        return;

      case WhatsNewDialogIntent():
        await showDialog(
          context: navCtx,
          builder: (BuildContext context) {
            return WhatsNewDialog(version: intent.version);
          },
        ).then(
          (_) => navCtx.read<AppFlagsRepository>().setShownWhatsNewDialog(intent.version),
        );
        return;

      case FeedbackSurveyIntent():
        await showDialog(
          context: navCtx,
          builder: (BuildContext context) {
            return FeedbackSurveyDialog(surveyNumber: intent.surveyNumber);
          },
        ).then(
          (_) => navCtx.read<AppFlagsRepository>().setLastFeedbackSurveyNumber(intent.surveyNumber),
        );
        return;

      case AchievementCompleteIntent():
        await Future.delayed(Duration(seconds: 1));

        await showDialog(
          context: navCtx,
          barrierDismissible: false,
          builder: (context) {
            return AchievementsCompletedDialog(recentlyCompletedAchievements: intent.achievements);
          },
        );
        return;

      case BulkMunroUpdateDialogIntent():
        navCtx.read<Analytics>().track(AnalyticsEvent.bulkMunroUpdateDidalogShown);

        await showDialog(
          context: navCtx,
          builder: (BuildContext context) {
            return BulkMunroUpdateDialog();
          },
        ).then(
          (_) => navCtx.read<AppFlagsRepository>().setShowBulkMunroDialog(false),
        );

        return;

      case AnnualMunroChallengeDialogIntent():
        navCtx.read<Analytics>().track(AnalyticsEvent.annualMunroChallengeDialogShown);

        final go = await showDialog(
          context: navCtx,
          builder: (BuildContext context) {
            return AnnualMunroChallengeDialog(achievement: intent.achievement);
          },
        );

        if (go == true) {
          navCtx.read<Analytics>().track(AnalyticsEvent.annualMunroChallengeDialogConfirmed);
          navCtx.read<AchievementsState>()
            ..reset()
            ..setCurrentAchievement = intent.achievement;
          Navigator.of(navCtx).pushNamed(MunroChallengeDetailScreen.route);
        }
    }
  }
}
