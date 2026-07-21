import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:two_eight_two/analytics/analytics.dart';

Future<void> maybeShowReviewPrompt(BuildContext context) async {
  final rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 2,
    minLaunches: 2,
    remindDays: 5,
    remindLaunches: 5,
  );

  await rateMyApp.init();

  if (context.mounted && rateMyApp.shouldOpenDialog) {
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
}
