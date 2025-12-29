import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class UnitsSettingsScreen extends StatelessWidget {
  static const String route = '${SettingsScreen.route}/units';
  const UnitsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SwitchListTile(
            value: settingsState.metricHeight,
            onChanged: (value) {
              settingsState.setMetricHeight(value);
            },
            title: const Text('Units for height'),
            subtitle: settingsState.metricHeight ? const Text('Meters') : const Text('Feet'),
          ),
          SwitchListTile(
            value: settingsState.metricTemperature,
            onChanged: (value) {
              settingsState.setMetricTemperature(value);
            },
            title: const Text('Units for temperature'),
            subtitle: settingsState.metricTemperature ? const Text('Celcius') : const Text('Fahrenheit'),
          ),
        ],
      ),
    );
  }
}
