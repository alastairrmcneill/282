import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics_base.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FeedbackSurvey extends StatefulWidget {
  final Widget child;

  const FeedbackSurvey({required this.child, Key? key}) : super(key: key);

  @override
  _FeedbackSurveyState createState() => _FeedbackSurveyState();
}

class _FeedbackSurveyState extends State<FeedbackSurvey> {
  bool _hasShownDialog = false;
  TextEditingController _feedbackController1 = TextEditingController();
  TextEditingController _feedbackController2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndShowSurveyDialog();
  }

  void _checkAndShowSurveyDialog() async {
    if (_hasShownDialog) return;
    _hasShownDialog = true;
    final appFlagsRepository = context.read<AppFlagsRepository>();
    int currentFeedbackSurveyNumber = context.read<RemoteConfigState>().config.feedbackSurveyNumber;

    int lastFeedbackSurveyNumber = appFlagsRepository.lastFeedbackSurveyNumber;

    if (lastFeedbackSurveyNumber == -1) {
      await appFlagsRepository.setLastFeedbackSurveyNumber(currentFeedbackSurveyNumber);
      return;
    }

    if (!(currentFeedbackSurveyNumber > lastFeedbackSurveyNumber)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSurveyDialog(context, surveyNumber: currentFeedbackSurveyNumber);
    });
  }

  void _submit(FeedbackRepository repository, int surveyNumber) async {
    final userId = context.read<AuthState>().currentUserId;
    String response1 = _feedbackController1.text;
    String response2 = _feedbackController2.text;

    bool isIOS = Platform.isIOS;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;

    AppFeedback feedback = AppFeedback(
      userId: userId ?? "No User",
      dateProvided: DateTime.now(),
      surveyNumber: surveyNumber,
      feedback1: response1,
      feedback2: response2,
      version: appVersion,
      platform: isIOS ? "iOS" : "Android",
    );

    context.read<Analytics>().track(AnalyticsEvent.surveyAnswers, props: {
      AnalyticsProp.q1: response1.isNotEmpty,
      AnalyticsProp.q2: response2.isNotEmpty,
    });
    if (response1.isEmpty && response2.isEmpty) {
      return;
    }
    await repository.create(feedback: feedback);

    showSnackBar(context, "Thank you for your feedback! 🙏");
  }

  void _showSurveyDialog(BuildContext context, {required int surveyNumber}) {
    final feedbackRepository = context.read<FeedbackRepository>();
    context.read<Analytics>().track(AnalyticsEvent.surveyShown);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          onPopInvoked: (didPop) {
            if (didPop) {
              context.read<AppFlagsRepository>().setLastFeedbackSurveyNumber(surveyNumber);
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi there 👋, Alastair here (founder of 282). I hope you've been enjoying the 282 app so far. I'm always looking for ways to improve the experience for users and so please can you help me out by answering a couple of questions below: ",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'What do you like most about 282?',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _feedbackController1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Type here...',
                              hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'What would you like to see added to 282?',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _feedbackController2,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Type here...',
                              hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _submit(feedbackRepository, surveyNumber);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
