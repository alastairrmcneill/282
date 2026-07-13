import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

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
    await rateMyApp.showRateDialog(context);
  }
}
