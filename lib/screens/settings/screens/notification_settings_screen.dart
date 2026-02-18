import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});
  static const String route = '${SettingsScreen.route}/notifications';

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SwitchListTile(
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
            title: const Text('Push notifications'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: Text(
              'Push notifications are only used to update you on activities to your profile such as follows, likes and comments.',
            ),
          )
        ],
      ),
    );
  }
}
