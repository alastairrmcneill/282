import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class PasswordRequirementsWidget extends StatelessWidget {
  final String password;
  final String confirmPassword;

  const PasswordRequirementsWidget({
    super.key,
    required this.password,
    required this.confirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border, width: 0.65),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequirementItem(met: RegExp(r'[A-Z]').hasMatch(password), text: 'At least one uppercase letter'),
          const SizedBox(height: 6),
          _RequirementItem(met: RegExp(r'[a-z]').hasMatch(password), text: 'At least one lowercase letter'),
          const SizedBox(height: 6),
          _RequirementItem(met: RegExp(r'\d').hasMatch(password), text: 'At least one digit'),
          const SizedBox(height: 6),
          _RequirementItem(
            met: RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
            text: 'At least one special character',
          ),
          const SizedBox(height: 6),
          _RequirementItem(met: password.length >= 8, text: 'At least 8 characters'),
          if (confirmPassword.isNotEmpty) ...[
            const SizedBox(height: 6),
            _RequirementItem(met: password == confirmPassword, text: 'Passwords match'),
          ],
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final bool met;
  final String text;

  const _RequirementItem({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: met ? context.colors.accent : context.colors.border,
          ),
          child: met ? const Icon(Icons.check, color: Colors.white, size: 11) : null,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: met ? context.colors.accent : context.colors.textSubtitle,
              ),
        ),
      ],
    );
  }
}
