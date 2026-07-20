import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class AppleSignInButton extends StatelessWidget {
  final SignInWithAppleButtonStyle? style;
  final void Function(String)? onError;
  final String? gateSource;
  const AppleSignInButton({super.key, this.style, this.onError, this.gateSource});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (Platform.isIOS) {
      return SignInWithAppleButton(
        style: style ?? (isDark ? SignInWithAppleButtonStyle.white : SignInWithAppleButtonStyle.black),
        onPressed: () async {
          final authResult = await context
              .read<AuthState>()
              .signInWithApple(source: gateSource != null ? 'in_app_onboarding' : null, gateSource: gateSource);
          if (authResult.success && authResult.showOnboarding && authResult.userId != null) {
            Navigator.pushNamed(
              context,
              InAppOnboardingScreen.route,
              arguments: InAppOnboardingScreenArgs(userId: authResult.userId!, gateSource: gateSource),
            );
          } else if (authResult.success) {
            // Load munro completions before navigating to home
            await context.read<MunroCompletionState>().loadUserMunroCompletions();
            Navigator.pushNamedAndRemoveUntil(
              context,
              HomeScreen.route,
              (route) => false,
            );
          } else if (!authResult.canceled) {
            onError?.call('Sign in failed. Please try again.');
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
