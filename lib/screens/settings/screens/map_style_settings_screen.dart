import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/option_list_tile.dart';

class MapStyleSettingsScreen extends StatelessWidget {
  static const String route = '${SettingsScreen.route}/map-style';
  const MapStyleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Style'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pin Colours', style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Choose how munro pins are coloured on the map.',
              style: textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  OptionListTile(
                    title: 'Regions',
                    subtitle: "Each of Scotland's munro regions gets its own colour.",
                    value: MapStyleOption.regions,
                    groupValue: settingsState.mapStyleSetting,
                    onChanged: (value) => settingsState.setMapStyle(value),
                  ),
                  Divider(indent: 15, endIndent: 15),
                  OptionListTile(
                    title: 'Classic',
                    subtitle: 'Simple red, green and blue pins for at-a-glance progress.',
                    value: MapStyleOption.classic,
                    groupValue: settingsState.mapStyleSetting,
                    onChanged: (value) => settingsState.setMapStyle(value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
