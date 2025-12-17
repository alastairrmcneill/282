import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

// Apple sign in button for login screen
class AppleSignInButton extends StatelessWidget {
  final SignInWithAppleButtonStyle? style;
  const AppleSignInButton({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      // Check if the device is an iOS device
      return SignInWithAppleButton(
        style: style ?? SignInWithAppleButtonStyle.white,
        onPressed: () async {
          final authResult = await context.read<AuthState>().signInWithApple();
          if (authResult.success && authResult.showOnboarding) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              InAppOnboarding.route,
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              HomeScreen.route,
              (route) => false,
            );
          }
        },
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      );
    } else {
      // If not then return nothing
      return const SizedBox();
    }
  }
}
