import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, required this.child});
  final Widget child;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppBootstrapState>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBootstrapState = context.watch<AppBootstrapState>();

    if (appBootstrapState.status == AppBootstrapStatus.initial ||
        appBootstrapState.status == AppBootstrapStatus.loading) {
      return const SplashScreen();
    }

    if (!appBootstrapState.hasCompletedOnboarding) {
      return OnboardingScreen();
    }

    return widget.child;
  }
}
