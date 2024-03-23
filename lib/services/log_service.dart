import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class Log {
  static void error(String message, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      print("ERROR: $message");
      print("Stack Trace: $stackTrace");
    } else {
      Sentry.captureException(
        Exception(message),
        stackTrace: stackTrace,
      );
    }
  }

  static void fatal(FlutterErrorDetails details) {
    if (kDebugMode) {
      print("FATAL: ${details.exception}");
      print(details.stack);
    } else {
      Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
      );
    }
  }
}
