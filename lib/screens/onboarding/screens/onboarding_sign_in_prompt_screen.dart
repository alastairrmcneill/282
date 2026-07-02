import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/onboarding/screens/onboarding_notifications_screen.dart';
import 'package:two_eight_two/support/legal_urls.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class OnboardingSignInPromptScreen extends StatefulWidget {
  static const String route = '/onboarding/sign_in_prompt';
  const OnboardingSignInPromptScreen({super.key});

  @override
  State<OnboardingSignInPromptScreen> createState() => _OnboardingSignInPromptScreenState();
}

class _OnboardingSignInPromptScreenState extends State<OnboardingSignInPromptScreen> {
  String? _errorMessage;

  Future<void> _handleAuthResult(AuthResult result) async {
    if (!mounted) return;
    if (result.success && result.userId != null) {
      await context.read<MunroCompletionState>().loadUserMunroCompletions();
      if (mounted) {
        Navigator.pushNamed(context, OnboardingNotificationsScreen.route);
      }
    } else if (!result.canceled) {
      setState(() => _errorMessage = 'Sign in failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = context.watch<BulkMunroUpdateState>().addedMunroCompletions.length;
    final isLoading = context.watch<AuthState>().status == AuthStatus.loading;

    final String headline = count > 0 ? 'Save your $count ${count == 1 ? 'Munro' : 'Munros'}' : 'Create your account';

    final String subtext = count > 0
        ? "Sign in or create a free account to save your progress and start tracking your Munro journey."
        : "Create a free account to track your Munros and connect with fellow baggers.";

    return Scaffold(
      body: Stack(
        children: [
          // Background photo — same as AuthHomeScreen
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_background1.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Dark overlay so text is readable
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.35)),
          ),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 0.3, color: Colors.white54),
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6),
                              onPressed: isLoading ? null : () => Navigator.pop(context),
                              icon: const Icon(Icons.chevron_left, size: 22, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Spacer pushes headline toward center
                    const Expanded(flex: 1, child: SizedBox()),
                    // Dynamic headline + subtext
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headline,
                            style: const TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtext,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[900]?.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Apple sign-in (iOS only)
                    if (Platform.isIOS) ...[
                      SignInWithAppleButton(
                        style: SignInWithAppleButtonStyle.white,
                        height: 52,
                        borderRadius: BorderRadius.circular(100),
                        onPressed: () async {
                          setState(() => _errorMessage = null);
                          final result = await context.read<AuthState>().signInWithApple();
                          if (mounted) await _handleAuthResult(result);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Google sign-in
                    _OnboardingGoogleButton(
                      onResult: (result) async {
                        setState(() => _errorMessage = null);
                        await _handleAuthResult(result);
                      },
                    ),
                    const SizedBox(height: 15),
                    const _TextDivider(),
                    const SizedBox(height: 15),
                    // Create free account (email signup)
                    CtaButton(
                      height: 52,
                      disabled: isLoading,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        SignUpScreen.route,
                        arguments: const SignUpScreenArgs(fromOnboarding: true),
                      ),
                      child: const Text(
                        'Create a free account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Already have an account?
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: const TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: 'Log in',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              color: Colors.white,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.pushNamed(
                                    context,
                                    LoginScreen.route,
                                    arguments: const LoginScreenArgs(fromOnboarding: true),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Terms & privacy
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'By continuing to use 282, you agree to our ',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              color: Colors.white,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = openTermsUrl,
                          ),
                          const TextSpan(text: ' and ', style: TextStyle(color: Colors.white70)),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              color: Colors.white,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = openPrivacyPolicyUrl,
                          ),
                          const TextSpan(text: '.', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) BlockingLoadingOverlay(),
        ],
      ),
    );
  }
}

class _OnboardingGoogleButton extends StatelessWidget {
  final Future<void> Function(AuthResult) onResult;
  const _OnboardingGoogleButton({required this.onResult});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color.fromRGBO(80, 124, 241, 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        onPressed: () async {
          final result = await context.read<AuthState>().signInWithGoogle();
          await onResult(result);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 24,
              width: 24,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
              child: Image.asset('assets/images/google_icon.png'),
            ),
            const SizedBox(width: 10),
            const Text('Continue with Google', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _TextDivider extends StatelessWidget {
  const _TextDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3), thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3), thickness: 0.5)),
      ],
    );
  }
}
