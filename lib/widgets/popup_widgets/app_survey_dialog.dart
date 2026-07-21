import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics_base.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FeedbackSurveyDialog extends StatelessWidget {
  final int surveyNumber;

  FeedbackSurveyDialog({super.key, required this.surveyNumber});

  final TextEditingController _feedbackController1 = TextEditingController();
  final TextEditingController _feedbackController2 = TextEditingController();

  Future<bool> _submit(
    FeedbackRepository repository,
    int surveyNumber,
    String? userId,
    String response1,
    String response2,
  ) async {
    if (response1.isEmpty && response2.isEmpty) return false;

    final bool isIOS = Platform.isIOS;
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final AppFeedback feedback = AppFeedback(
      userId: userId ?? 'No User',
      dateProvided: DateTime.now(),
      surveyNumber: surveyNumber,
      feedback1: response1,
      feedback2: response2,
      version: packageInfo.version,
      platform: isIOS ? 'iOS' : 'Android',
    );

    await repository.create(feedback: feedback);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthState>().currentUserId;
    final feedbackRepository = context.read<FeedbackRepository>();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<AppFlagsRepository>().setLastFeedbackSurveyNumber(surveyNumber);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi there 👋',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                "Alastair here, founder of 282. I hope you've been enjoying the app! I'm always looking for ways to improve — please can you help me out by answering a couple of quick questions?",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'What do you like most about 282?',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'What would you like to see added to 282?',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: () async {
                  final response1 = _feedbackController1.text;
                  final response2 = _feedbackController2.text;
                  final analytics = context.read<Analytics>();
                  final navigator = Navigator.of(context);

                  final saved = await _submit(feedbackRepository, surveyNumber, userId, response1, response2);
                  if (saved) {
                    analytics.track(AnalyticsEvent.surveyAnswers, props: {
                      AnalyticsProp.surveyNumber: surveyNumber,
                    });
                  }
                  if (context.mounted) showSnackBar(context, 'Thank you for your feedback! 🙏');
                  navigator.pop();
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
