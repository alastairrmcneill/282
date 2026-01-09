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
