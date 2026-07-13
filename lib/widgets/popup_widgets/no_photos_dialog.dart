import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class NoPhotosDialog extends StatelessWidget {
  const NoPhotosDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.camera,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops, no photos!',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Would you like to add some awesome photos to your post before sharing your adventure?',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              analyticsEvent: AnalyticsEvent.createPostNoPhotosDialogResponse,
              analyticsProperties: const {AnalyticsProp.response: "add"},
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Yes, Add Photos!'),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              analyticsEvent: AnalyticsEvent.createPostNoPhotosDialogResponse,
              analyticsProperties: const {AnalyticsProp.response: "skip"},
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('No, Skip'),
            ),
          ],
        ),
      ),
    );
  }
}
