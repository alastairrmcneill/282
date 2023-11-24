import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/services/push_notification_service.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.initPushNotificaitons();
  runApp(App(flavor: "Development"));
}
