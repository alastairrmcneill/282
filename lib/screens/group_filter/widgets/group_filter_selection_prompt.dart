import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/support/theme.dart';

class GroupFilterSelectionPrompt extends StatelessWidget {
  const GroupFilterSelectionPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIconsRegular.mapTrifold, color: colors.accent, size: 36),
          const SizedBox(height: 12),
          Text(
            "Tap \"View Munros\" below to see what Munros you have left between you.",
            style: textTheme.bodyMedium?.copyWith(color: colors.textSubtitle),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
