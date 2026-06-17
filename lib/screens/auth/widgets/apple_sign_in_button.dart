import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class AppleSignInButton extends StatelessWidget {
  final SignInWithAppleButtonStyle? style;
  const AppleSignInButton({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (Platform.isIOS) {
      return SignInWithAppleButton(
        style: style ?? (isDark ? SignInWithAppleButtonStyle.white : SignInWithAppleButtonStyle.black),
        onPressed: () async {
          final authResult = await context.read<AuthState>().signInWithApple();
          if (authResult.success && authResult.showOnboarding && authResult.userId != null) {
            Navigator.pushNamed(
              context,
              InAppOnboardingScreen.route,
              arguments: InAppOnboardingScreenArgs(userId: authResult.userId!),
            );
          } else if (authResult.success) {
            // Load munro completions before navigating to home
            await context.read<MunroCompletionState>().loadUserMunroCompletions();
            Navigator.pushNamedAndRemoveUntil(
              context,
              HomeScreen.route,
              (route) => false,
            );
          }
        },
        height: 48,
        borderRadius: BorderRadius.circular(100),
      );
    } else {
      // If not then return nothing
      return const SizedBox();
    }
  }
}
