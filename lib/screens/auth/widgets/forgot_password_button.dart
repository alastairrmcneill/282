import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pushNamed(ForgotPasswordScreen.route),
      child: const Text('Forgot your password?'),
    );
  }
}
