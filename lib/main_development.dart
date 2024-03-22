import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/services/services.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.initPushNotificaitons();

  FlutterError.onError = (FlutterErrorDetails details) => Log.fatal(details);
  runApp(App(flavor: "Development"));
}
