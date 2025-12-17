import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class SignInButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  const SignInButton({Key? key, required this.formKey, required this.emailController, required this.passwordController})
      : super(key: key);

  Future _signIn(BuildContext context) async {
    final authResult = await context.read<AuthState>().signInWithEmail(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

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
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: () async {
          if (!formKey.currentState!.validate()) {
            return;
          }
          formKey.currentState!.save();
          await _signIn(context);
        },
        child: const Text('Sign In'),
      ),
    );
  }
}
