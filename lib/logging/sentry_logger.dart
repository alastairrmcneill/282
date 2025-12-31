import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:two_eight_two/logging/logging.dart';

class SentryLogger implements Logger {
  @override
  void info(String message, {Map<String, Object?>? context}) {
    if (kDebugMode) {
      debugPrint('INFO: $message');
      if (context != null) debugPrint('CTX: $context');
      return;
    }
    Sentry.captureMessage(message, level: SentryLevel.info);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, Object?>? context}) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) debugPrint('ERR: $error');
      if (context != null) debugPrint('CONTEXT: $context');
      if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
      return;
    }

    Sentry.captureException(
      error ?? Exception(message),
      stackTrace: stackTrace,
      withScope: (scope) {
        if (context != null) {
          context.forEach((name, data) {
            scope.setContexts(name, data);
          });
        }
      },
    );
  }

  @override
  void fatal(Object error, {StackTrace? stackTrace, Map<String, Object?>? context}) {
    if (kDebugMode) {
      debugPrint('FATAL: $error');
      if (context != null) debugPrint('CTX: $context');
      if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
      return;
    }

    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (context != null) {
          context.forEach((name, data) {
            scope.setContexts(name, data);
          });
        }
      },
    );
  }

  @override
  void identify(String userId) {
    if (kDebugMode) {
      debugPrint('IDENTIFY: $userId');
      return;
    }
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId));
    });
  }

  @override
  void clearUser() {
    if (kDebugMode) {
      debugPrint('CLEAR USER');
      return;
    }
    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }
}
