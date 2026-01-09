import 'package:flutter/material.dart';

class InAppOnboardingNotifications extends StatelessWidget {
  const InAppOnboardingNotifications({super.key});
  static const String route = '/in_app_onboarding/notifications';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, right: 30, left: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
        ],
      ),
    );
  }
}
