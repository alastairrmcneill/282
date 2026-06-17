import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ForgotPasswordFormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final VoidCallback onSubmit;
  final String? error;
  final bool isLoading;

  const ForgotPasswordFormView({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.onSubmit,
    required this.isLoading,
    this.error,
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
          child: Icon(Icons.mail_outline_rounded, size: 40, color: colors.accent),
        ),
        const SizedBox(height: 24),
        Text(
          'Reset your password',
          style: textTheme.headlineMedium?.copyWith(color: colors.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Enter your email address and we'll send you a link to reset your password.",
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: colors.textSubtitle),
        ),
        const SizedBox(height: 32),
        if (error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Text(
              error!,
              style: textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Form(
          key: formKey,
          child: Column(
            children: [
              EmailFormField(textEditingController: emailController),
              const SizedBox(height: 16),
              CtaButton(
                onPressed: isLoading ? null : onSubmit,
                disabled: isLoading,
                child: Text(isLoading ? 'Sending...' : 'Send reset link'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
