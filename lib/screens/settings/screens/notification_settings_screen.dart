import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});
  static const String route = '${SettingsScreen.route}/notifications';

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('Push notifications', style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Notifications will be sent for new followers, comments, and likes on posts.',
              style: textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: settingsState.enablePushNotifications,
              onChanged: (value) async {
                // Optimistically update local preference
                await settingsState.setEnablePushNotifications(value);

                final ok = await context.read<PushNotificationState>().onPushSettingChanged();

                // If user tried to enable but OS permission denied, revert preference
                if (value == true && ok == false) {
                  await settingsState.setEnablePushNotifications(false);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enable notifications in system settings to receive pushes.')),
                    );
                  }
                }
              },
              title: const Text('Allow notifications'),
            ),
          ],
        ),
      ),
    );
  }
}
