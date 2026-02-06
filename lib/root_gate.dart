import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingState>();

    return onboarding.hasCompletedOnboarding ? const HomeScreen(startingIndex: 0) : const OnboardingScreen();
  }
}
