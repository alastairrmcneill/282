import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/app.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App(flavor: "Production"));
}
