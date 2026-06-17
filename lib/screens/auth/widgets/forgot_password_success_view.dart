import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ForgotPasswordSuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBackToLogin;
  final VoidCallback onTryAgain;

  const ForgotPasswordSuccessView({
    super.key,
    required this.email,
    required this.onBackToLogin,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.check_rounded, size: 40, color: colors.accent),
        ),
        const SizedBox(height: 24),
        Text(
          'Check your email',
          style: textTheme.headlineMedium?.copyWith(color: colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "We've sent a password reset link to:",
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: colors.textSubtitle),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Didn't receive the email? Check your spam folder or try again.",
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: colors.textSubtitle),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          onPressed: onBackToLogin,
          child: const Text('Back to login'),
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          onPressed: onTryAgain,
          child: const Text('Try different email'),
        ),
      ],
    );
  }
}
