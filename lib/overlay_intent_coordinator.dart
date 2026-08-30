import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/review_prompt.dart';
import 'package:two_eight_two/widgets/widgets.dart';

import 'screens/nav/widgets/widgets.dart';

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
        navCtx.read<Analytics>().track(
          AnalyticsEvent.dialogShown,
          props: {AnalyticsProp.dialogName: AnalyticsDialog.hardAppUpdate},
        );
        showDialog(
          context: navCtx,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return HardUpdateDialog();
          },
        );
        return;
      case SoftUpdateDialogIntent():
        navCtx.read<Analytics>().track(
          AnalyticsEvent.dialogShown,
          props: {AnalyticsProp.dialogName: AnalyticsDialog.softAppUpdate},
        );

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
        navCtx.read<Analytics>().track(
          AnalyticsEvent.dialogShown,
          props: {
            AnalyticsProp.dialogName: AnalyticsDialog.whatsNew,
            AnalyticsProp.version: intent.version,
          },
        );

        final whatsNewResponse = await showDialog<String>(
          context: navCtx,
          builder: (BuildContext context) {
            return WhatsNewDialog(version: intent.version);
          },
        );

        navCtx.read<Analytics>().track(
          AnalyticsEvent.dialogResponse,
          props: {
            AnalyticsProp.dialogName: AnalyticsDialog.whatsNew,
            AnalyticsProp.version: intent.version,
            AnalyticsProp.response: whatsNewResponse ?? AnalyticsResponse.dismiss,
          },
        );

        await navCtx.read<AppFlagsRepository>().setShownWhatsNewDialog(intent.version);
        return;

      case FeedbackSurveyIntent():
        navCtx.read<Analytics>().track(
          AnalyticsEvent.surveyShown,
          props: {AnalyticsProp.surveyNumber: intent.surveyNumber},
        );

        await showDialog(
          context: navCtx,
          builder: (BuildContext context) {
            return FeedbackSurveyDialog(surveyNumber: intent.surveyNumber);
          },
        ).then((_) {
          final appFlagsRepository = navCtx.read<AppFlagsRepository>();
          appFlagsRepository.setLastFeedbackSurveyNumber(intent.surveyNumber);
          appFlagsRepository.setFeedbackSurveyOpenCount(0);
        });
        return;

      case AchievementCompleteIntent():
        await Future.delayed(Duration(seconds: 1));

        navCtx.read<Analytics>().track(
          AnalyticsEvent.dialogShown,
          props: {
            AnalyticsProp.dialogName: AnalyticsDialog.achievementUnlocked,
            AnalyticsProp.achievementCount: intent.achievements.length,
          },
        );

        await showDialog(
          context: navCtx,
          barrierDismissible: false,
          builder: (context) {
            return AchievementsCompletedDialog(recentlyCompletedAchievements: intent.achievements);
          },
        ).then((_) => maybeShowReviewPrompt(navCtx));
        return;

      case BulkMunroUpdateDialogIntent():
        navCtx.read<Analytics>().track(
          AnalyticsEvent.dialogShown,
          props: {AnalyticsProp.dialogName: AnalyticsDialog.bulkMunroUpdate},
        );

        final wantsBulk = await showDialog<bool>(
          context: navCtx,
          builder: (BuildContext context) {
            return const BulkMunroUpdateDialog();
          },
        );

        navCtx.read<Analytics>().track(
          AnalyticsEvent.dialogResponse,
          props: {
            AnalyticsProp.dialogName: AnalyticsDialog.bulkMunroUpdate,
            AnalyticsProp.response: wantsBulk == true ? AnalyticsResponse.go : AnalyticsResponse.dismiss,
          },
        );

        await navCtx.read<AppFlagsRepository>().setShowBulkMunroDialog(false);

        if (wantsBulk == true) {
          Navigator.of(navCtx).pushNamed(BulkMunroUpdateScreen.route);
        }

        return;

      case AnnualMunroChallengeDialogIntent():
        navCtx.read<Analytics>().track(
          AnalyticsEvent.dialogShown,
          props: {AnalyticsProp.dialogName: AnalyticsDialog.annualMunroChallenge},
        );

        final go = await showDialog(
          context: navCtx,
          builder: (BuildContext context) {
            return AnnualMunroChallengeDialog(achievement: intent.achievement);
          },
        );

        await navCtx.read<AppFlagsRepository>().setShownAnnualChallengeDialog(
              '${intent.achievement.userId}-${intent.achievement.achievementId}',
            );

        navCtx.read<Analytics>().track(
          AnalyticsEvent.dialogResponse,
          props: {
            AnalyticsProp.dialogName: AnalyticsDialog.annualMunroChallenge,
            AnalyticsProp.response: go == true ? AnalyticsResponse.confirmed : AnalyticsResponse.dismissed,
          },
        );

        if (go == true) {
          navCtx.read<AchievementsState>()
            ..reset()
            ..setCurrentAchievement = intent.achievement;
          Navigator.of(navCtx).pushNamed(MunroChallengeDetailScreen.route);
        }
        return;

      case ReviewPromptIntent():
        await maybeShowReviewPrompt(navCtx);
        return;

      case StravaReviewActivityIntent():
        navCtx.read<Analytics>().track(
          AnalyticsEvent.dialogShown,
          props: {AnalyticsProp.dialogName: AnalyticsDialog.stravaReviewActivity},
        );
        final reviews = await navCtx.read<StravaActivityReviewState>().loadPendingReviews();
        if (reviews.isEmpty || !navCtx.mounted) return;

        if (reviews.length == 1) {
          await StravaMatchesReviewBottomSheet.show(navCtx);
        } else {
          await StravaMatchesSummaryBottomSheet.show(navCtx);
        }
        return;
    }
  }
}
