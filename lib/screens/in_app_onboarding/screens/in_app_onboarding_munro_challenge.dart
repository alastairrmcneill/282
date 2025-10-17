import 'package:flutter/material.dart';
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
    AchievementsState achievementsState = Provider.of<AchievementsState>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Challenge yourself!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'What is your target for munros to complete this year? 🎯',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 30),
          Form(
            key: args.formKey,
            child: TextFormFieldBase(
              initialValue: achievementsState.currentAchievement?.annualTarget.toString() ?? '0',
              labelText: "Number of Munros",
              textInputAction: TextInputAction.done,
              fillColor: Colors.white,
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
                achievementsState.setAchievementFormCount = int.parse(value!);
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
