import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen())),
      child: const Text('Forgot your password?'),
    );
  }
}
