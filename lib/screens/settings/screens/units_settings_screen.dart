import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/option_list_tile.dart';

class UnitsSettingsScreen extends StatelessWidget {
  static const String route = '${SettingsScreen.route}/units';
  const UnitsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Units'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Temperature', style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('Choose your preferred temperature unit for weather information.',
                style: textTheme.bodyMedium?.copyWith(color: context.colors.textMuted)),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  OptionListTile(
                    title: 'Celsius (°C)',
                    trailing: Text(
                      '15°C',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
                    ),
                    value: true,
                    groupValue: settingsState.metricTemperature,
                    onChanged: (value) {
                      settingsState.setMetricTemperature(value);
                    },
                  ),
                  Divider(indent: 15, endIndent: 15),
                  OptionListTile(
                    title: 'Fahrenheit (°F)',
                    trailing: Text(
                      '59°F',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
                    ),
                    value: false,
                    groupValue: settingsState.metricTemperature,
                    onChanged: (value) {
                      settingsState.setMetricTemperature(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Height', style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('Choose your preferred height unit for munro elevations.',
                style: textTheme.bodyMedium?.copyWith(color: context.colors.textMuted)),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: RadioGroup<bool>(
                  groupValue: settingsState.metricHeight,
                  onChanged: (value) {
                    settingsState.setMetricHeight(value!);
                  },
                  child: Column(
                    children: [
                      OptionListTile(
                          title: 'Meters (m)',
                          trailing: Text(
                            '1,218 m',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
                          ),
                          value: true,
                          groupValue: settingsState.metricHeight,
                          onChanged: (value) {
                            settingsState.setMetricHeight(value);
                          }),
                      Divider(indent: 15, endIndent: 15),
                      OptionListTile(
                          title: 'Feet (ft)',
                          trailing: Text(
                            '3,996 ft',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
                          ),
                          value: false,
                          groupValue: settingsState.metricHeight,
                          onChanged: (value) {
                            settingsState.setMetricHeight(value);
                          }),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
