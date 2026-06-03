import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/option_list_tile.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  static const String route = '${SettingsScreen.route}/appearance';
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Choose how the app looks on your device.',
              style: textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  OptionListTile(
                    title: 'Light',
                    value: ThemeModeOption.light,
                    groupValue: settingsState.themeModeSetting,
                    onChanged: (value) => settingsState.setThemeMode(value),
                  ),
                  Divider(indent: 15, endIndent: 15),
                  OptionListTile(
                    title: 'System Default',
                    value: ThemeModeOption.system,
                    groupValue: settingsState.themeModeSetting,
                    onChanged: (value) => settingsState.setThemeMode(value),
                  ),
                  Divider(indent: 15, endIndent: 15),
                  OptionListTile(
                    title: 'Dark',
                    value: ThemeModeOption.dark,
                    groupValue: settingsState.themeModeSetting,
                    onChanged: (value) => settingsState.setThemeMode(value),
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
