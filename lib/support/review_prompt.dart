import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/widgets/widgets.dart';

const _sentimentPromptCooldown = Duration(days: 14);

Future<void> maybeShowReviewPrompt(BuildContext context) async {
  final rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 2,
    minLaunches: 2,
    remindDays: 5,
    remindLaunches: 5,
  );

  await rateMyApp.init();

  if (!context.mounted || !rateMyApp.shouldOpenDialog) return;

  final appFlags = context.read<AppFlagsRepository>();
  final lastAsked = appFlags.lastReviewSentimentPromptDate;
  if (lastAsked != null && DateTime.now().difference(lastAsked) < _sentimentPromptCooldown) return;
  await appFlags.setLastReviewSentimentPromptDate(DateTime.now());

  context.read<Analytics>().track(AnalyticsEvent.reviewSentimentPromptShown);

  final result = await showDialog<ReviewSentimentResult>(
    context: context,
    builder: (_) => const ReviewSentimentDialog(),
  );

  if (!context.mounted) return;
  context.read<Analytics>().track(
    AnalyticsEvent.reviewSentimentPromptResponse,
    props: {AnalyticsProp.response: (result ?? ReviewSentimentResult.negativeDeclined).name},
  );

  if (result != ReviewSentimentResult.positive) return;

  context.read<Analytics>().track(AnalyticsEvent.reviewPromptShown);

  await rateMyApp.showRateDialog(
    context,
    listener: (button) {
      context.read<Analytics>().track(
        AnalyticsEvent.reviewPromptResponse,
        props: {AnalyticsProp.response: button.name},
      );
      return true;
    },
  );
}
