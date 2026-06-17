import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
