import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/age_gate/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

/// Wraps [child] (the main app shell) behind a one-time age check, per
/// App Store Connect's "Social Media Disabled for Users Under 13"
/// requirement. Runs silently via Apple's Declared Age Range API where
/// possible; only surfaces UI when that's unavailable and a self-declared
/// birthdate is needed. No-op on Android, where this isn't required.
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
      AgeGateStatus.needsBirthdate => const Scaffold(body: BirthdatePromptView()),
      AgeGateStatus.checking => const Scaffold(body: LoadingWidget(text: null)),
    };
  }
}
