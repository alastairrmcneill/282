import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/onboarding/screens/munro_question_screen.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class InAppOnboardingScreenArgs {
  final String userId;
  final String? gateSource;

  InAppOnboardingScreenArgs({required this.userId, this.gateSource});
}

class InAppOnboardingScreen extends StatefulWidget {
  final InAppOnboardingScreenArgs args;
  static const String route = '/in_app_onboarding';

  const InAppOnboardingScreen({super.key, required this.args});

  @override
  State<InAppOnboardingScreen> createState() => _InAppOnboardingState();
}

class _InAppOnboardingState extends State<InAppOnboardingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InAppOnboardingState>().init(widget.args.userId);
    });
  }

  void _onMunroQuestionYes() {
    Navigator.of(context).pushNamed(
      OnboardingBulkLogScreen.route,
      arguments: const OnboardingBulkLogScreenArgs(alreadyAuthenticated: true),
    );
  }

  void _onMunroQuestionNo() {
    Navigator.of(context).pushNamed(
      OnboardingNotificationsScreen.route,
      arguments: const OnboardingNotificationsScreenArgs(fromInAppOnboarding: true, branch: 'no'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inAppOnboardingState = context.watch<InAppOnboardingState>();

    // Gate UI while loading
    if (inAppOnboardingState.status == InAppOnboardingStatus.loading ||
        inAppOnboardingState.status == InAppOnboardingStatus.initial) {
      return const Scaffold(body: LoadingWidget());
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: MunroQuestionScreen(
          onYes: _onMunroQuestionYes,
          onNo: _onMunroQuestionNo,
          source: 'in_app_onboarding',
        ),
      ),
    );
  }
}
