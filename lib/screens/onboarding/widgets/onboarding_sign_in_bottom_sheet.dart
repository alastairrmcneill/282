import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';

import 'package:two_eight_two/widgets/widgets.dart';

class OnboardingSignInBottomSheet extends StatelessWidget {
  const OnboardingSignInBottomSheet({super.key});

  static Future<void> show(
    BuildContext context,
  ) async {
    await showAppBottomSheet(
      context: context,
      builder: (context) => OnboardingSignInBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      isDismissible: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Munros logged!",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Finish signing up by creating a profile and getting the most out of 282, ",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 16),
        AppleSignInButton(),
        const SizedBox(height: 12),
        GoogleSignInButton(),
        const SizedBox(height: 12),
        CtaButton(
          height: 48,
          backgroundColor: context.colors.background,
          borderColor: context.colors.middleGrey,
          onPressed: () {},
          child: Text(
            'Use my email',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.colors.textSubtitle),
          ),
        ),
        const SizedBox(height: 16),
        ConsentText(),
        const SizedBox(height: 24),
      ],
    );
  }
}
