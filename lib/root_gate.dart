import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/screens/age_gate/age_gate_screen.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingState>();
    final auth = context.watch<AuthState>();

    final skipOnboarding = onboarding.hasCompletedOnboarding || auth.currentUserId != null;

    return skipOnboarding
        ? AgeGateScreen(child: HomeScreen(key: homeScreenKey, startingIndex: 0))
        : const OnboardingScreen();
  }
}
