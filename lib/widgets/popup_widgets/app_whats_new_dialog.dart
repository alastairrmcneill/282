import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/settings/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class WhatsNewDialog extends StatelessWidget {
  final String version;
  const WhatsNewDialog({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    final mapStyle = settingsState.mapStyleSetting;

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
              "at-a-glance progress, instead of a colour per region. Tap an option to try it.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _MapStyleOptionCard(
                    imagePath: 'assets/images/map-style-regions.png',
                    label: 'Regions',
                    selected: mapStyle == MapStyleOption.regions,
                    onTap: () => settingsState.setMapStyle(MapStyleOption.regions),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MapStyleOptionCard(
                    imagePath: 'assets/images/map-style-classic.png',
                    label: 'Classic',
                    selected: mapStyle == MapStyleOption.classic,
                    onTap: () => settingsState.setMapStyle(MapStyleOption.classic),
                  ),
                ),
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

class _MapStyleOptionCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MapStyleOptionCard({
    required this.imagePath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final captionStyle = Theme.of(context).textTheme.labelMedium?.copyWith(color: context.colors.textMuted);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: selected ? Border.all(color: context.colors.accent, width: 2.5) : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(selected ? 11 : 12),
                  child: AspectRatio(
                    aspectRatio: 820 / 790,
                    child: Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  top: -9,
                  left: -9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Selected',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: captionStyle),
        ],
      ),
    );
  }
}
