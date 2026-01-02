import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Must re-init Firebase in background isolate.
  await Firebase.initializeApp();

  // Do background-safe work only (e.g. log, local persistence).
  // Do NOT navigate, do NOT read providers.
}
