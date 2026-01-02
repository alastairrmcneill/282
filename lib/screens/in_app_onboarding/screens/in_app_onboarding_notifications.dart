import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class InAppOnboardingNotifications extends StatelessWidget {
  const InAppOnboardingNotifications({super.key});
  static const String route = '/in_app_onboarding/notifications';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, right: 30, left: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Icon(
              Icons.notifications_active_outlined,
              size: 200,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
          ),
          Text(
            'Stay in the loop! 🔔',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'Get notified when your friends like, comment, or follow you. We\'ll only send notifications about activity on your profile.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await _handleEnableNotifications(context);
            },
            child: const Text('Enable Notifications'),
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () async {
              await _handleDenyNotifications(context);
            },
            child: const Text('Not Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEnableNotifications(BuildContext context) async {
    final settingsState = context.read<SettingsState>();
    final pushState = context.read<PushNotificationState>();

    // Update settings to enable
    await settingsState.setEnablePushNotifications(true);

    // Request permission and sync token
    final granted = await pushState.enablePush();

    // If OS permission denied, revert setting
    if (!granted) {
      await settingsState.setEnablePushNotifications(false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable notifications in system settings to receive updates.'),
          ),
        );
      }
    }
  }

  Future<void> _handleDenyNotifications(BuildContext context) async {
    final settingsState = context.read<SettingsState>();
    final pushNotificationState = context.read<PushNotificationState>();
    final userState = context.read<UserState>();

    // Update local settings to disabled
    await settingsState.setEnablePushNotifications(false);
    await pushNotificationState.disablePush();

    // Clear FCM token from database
    final user = userState.currentUser;
    if (user != null) {
      await userState.updateUser(appUser: user.copyWith(fcmToken: ''));
    }
  }
}
