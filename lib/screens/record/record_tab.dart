import 'package:flutter/material.dart';
import 'package:two_eight_two/services/services.dart';

class RecordTab extends StatelessWidget {
  const RecordTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              PushNotificationService.initNotifications(context);
            },
            child: Text("Init Notifications")),
      ),
    );
  }
}
