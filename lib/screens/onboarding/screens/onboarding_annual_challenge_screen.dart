import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/in_app_onboarding/screens/in_app_onboarding_munro_challenge.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/onboarding/screens/onboarding_notifications_screen.dart';
import 'package:two_eight_two/screens/onboarding/widgets/onboarding_step_indicator.dart';

class OnboardingAnnualChallengeScreen extends StatefulWidget {
  static const String route = '/onboarding/annual_challenge';
  const OnboardingAnnualChallengeScreen({super.key});

  @override
  State<OnboardingAnnualChallengeScreen> createState() => _OnboardingAnnualChallengeScreenState();
}

class _OnboardingAnnualChallengeScreenState extends State<OnboardingAnnualChallengeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _setGoal() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    Navigator.pushNamed(context, OnboardingNotificationsScreen.route);
  }

  void _skip() {
    context.read<AchievementsState>().setAchievementFormCount = 0;
    Navigator.pushNamed(context, OnboardingNotificationsScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(LucideIcons.chevron_left, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            OnboardingStepIndicator(
              currentStep: 0,
              steps: const ['Set a goal', 'Notifications'],
            ),
            Expanded(
              child: InAppOnboardingMunroChallenge(
                args: InAppOnboardingMunroChallengeArgs(formKey: _formKey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF10b981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                      onPressed: _setGoal,
                      child: const Text(
                        'Set my goal',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip for now',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
