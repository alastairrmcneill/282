import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class InAppOnboardingMunroChallengeArgs {
  final GlobalKey<FormState> formKey;

  InAppOnboardingMunroChallengeArgs({required this.formKey});
}

class InAppOnboardingMunroChallenge extends StatelessWidget {
  final InAppOnboardingMunroChallengeArgs args;
  static const String route = '/in_app_onboarding/munro_challenge';
  const InAppOnboardingMunroChallenge({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final achievementsState = context.watch<AchievementsState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10b981).withOpacity(0.12),
              ),
              child: const Center(
                child: Icon(LucideIcons.target, size: 36, color: Color(0xFF10b981)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Set a Munro goal',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'How many Munros do you want to summit this year? Setting a goal keeps you motivated and on track.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 30),
          Form(
            key: args.formKey,
            child: AppTextFormField(
              initialValue: achievementsState.currentAchievement?.annualTarget?.toString() ?? '',
              labelText: 'Number of Munros (1–282)',
              textInputAction: TextInputAction.done,
              fillColor: Colors.white,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    int.tryParse(value) == null ||
                    int.parse(value) < 1 ||
                    int.parse(value) > 282) {
                  return 'Please enter a number between 1 and 282.';
                }
                return null;
              },
              onSaved: (value) {
                achievementsState.setAchievementFormCount = int.parse(value!.trim());
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF10b981).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.info, size: 18, color: Color(0xFF10b981)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Scotland has 282 Munros in total. A popular first-year goal is 10–20.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
