import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

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
            onChanged: (value) {
              settingsState.setEnablePushNotifications(value);
              if (value) {
                // Add FCM Token to database
                PushNotificationService.applyFCMToken(context);
              } else {
                // Remove FCM Token from database
                PushNotificationService.removeFCMToken(context);
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
