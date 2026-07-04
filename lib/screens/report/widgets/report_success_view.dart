import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReportSuccessView extends StatelessWidget {
  const ReportSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.2),
                width: 0.65,
              ),
            ),
            child: Icon(
              PhosphorIconsRegular.checkCircle,
              color: colors.accent,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Report received",
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "We've received your report and will take a look shortly.",
            style: textTheme.bodyMedium?.copyWith(color: colors.textSubtitle),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }
}
