import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class UnitsSettingsScreen extends StatelessWidget {
  const UnitsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsState settingsState = Provider.of<SettingsState>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SwitchListTile(
            value: settingsState.metricHeight,
            onChanged: (value) {
              settingsState.setMetricHeight = value;
              SettingsSerivce.setBoolSetting(
                settingName: SettingsFields.metricHeight,
                value: value,
              );
            },
            title: const Text('Units for height'),
            subtitle: settingsState.metricHeight ? const Text('Meters') : const Text('Feet'),
          ),
          SwitchListTile(
            value: settingsState.metricTemperature,
            onChanged: (value) {
              settingsState.setMetricTemperature = value;
              SettingsSerivce.setBoolSetting(
                settingName: SettingsFields.metricTemperature,
                value: value,
              );
            },
            title: const Text('Units for temperature'),
            subtitle: settingsState.metricTemperature ? const Text('Celcius') : const Text('Fahrenheit'),
          ),
        ],
      ),
    );
  }
}
