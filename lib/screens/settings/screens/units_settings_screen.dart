import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';

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
                style: textTheme.bodyMedium?.copyWith(color: MyColors.mutedText)),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: RadioGroup<bool>(
                  groupValue: settingsState.metricTemperature,
                  onChanged: (value) {
                    settingsState.setMetricTemperature(value!);
                  },
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        title: Text('Celsius (°C)'),
                        value: true,
                        secondary: Text('15°C'),
                      ),
                      RadioListTile<bool>(
                        title: Text('Fahrenheit (°F)'),
                        value: false,
                        secondary: Text('59°F'),
                      ),
                    ],
                  )),
            ),
            const SizedBox(height: 24),
            Text('Height', style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('Choose your preferred height unit for munro elevations.',
                style: textTheme.bodyMedium?.copyWith(color: MyColors.mutedText)),
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
                      RadioListTile<bool>(
                        title: Text('Meters (m)'),
                        value: true,
                        secondary: Text('1,345m'),
                      ),
                      RadioListTile<bool>(
                        title: Text('Feet (ft)'),
                        value: false,
                        secondary: Text('4,413ft'),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
