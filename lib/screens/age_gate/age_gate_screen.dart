import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/age_gate/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

/// Wraps [child] (the main app shell) behind a one-time age check, to
/// meet UK/EU child-safety obligations (e.g. the ICO Children's Code and
/// Online Safety Act) around social features and under-13 users. Shows a
/// primer screen explaining why before triggering the platform's native
/// age-range check (Apple's Declared Age Range API on iOS, Google Play's
/// Age Signals API on Android), then falls back to a self-declared
/// birthdate prompt if that's unavailable or declined.
class AgeGateScreen extends StatefulWidget {
  final Widget child;
  const AgeGateScreen({super.key, required this.child});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgeGateState>().checkAgeGate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AgeGateState>().status;

    return switch (status) {
      AgeGateStatus.allowed => widget.child,
      AgeGateStatus.restricted => const Scaffold(body: AgeRestrictedView()),
      AgeGateStatus.needsConfirmation => const Scaffold(body: AgeConfirmationPromptView()),
      AgeGateStatus.needsBirthdate => const Scaffold(body: BirthdatePromptView()),
      AgeGateStatus.checking => const Scaffold(body: LoadingWidget(text: null)),
    };
  }
}
