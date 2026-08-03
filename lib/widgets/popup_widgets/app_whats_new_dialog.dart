import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/settings/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class WhatsNewDialog extends StatelessWidget {
  final String version;
  const WhatsNewDialog({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    final captionStyle = Theme.of(context).textTheme.labelMedium?.copyWith(color: context.colors.textMuted);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "What's New",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Version $version',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 20),
            // TODO: Update content each release
            Text(
              'New: Classic map pins',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Prefer a simpler look? You can now switch to Classic pins: simple red, green and blue for "
              "at-a-glance progress, instead of a colour per region. Find it any time in Settings → Map Style.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/whats_new_map_style.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(child: Center(child: Text('Classic', style: captionStyle))),
                Expanded(child: Center(child: Text('Regions', style: captionStyle))),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () => Navigator.of(context).pop(AnalyticsResponse.dismiss),
              child: const Text('Got it'),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop(AnalyticsResponse.openSettings);
                navigator.pushNamed(MapStyleSettingsScreen.route);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
