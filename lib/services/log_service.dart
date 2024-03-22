import 'package:flutter/material.dart';

class Log {
  static void info(String message) {
    print("INFO: $message");
  }

  static void error(String message, {StackTrace? stackTrace}) {
    print("ERROR: $message");
    print("Stack Trace: $stackTrace");
  }

  static void fatal(FlutterErrorDetails details) {
    print("FATAL: ${details.exception}");
    print(details.stack);
  }
}
