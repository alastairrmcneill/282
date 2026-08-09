import 'package:two_eight_two/helpers/helpers.dart';

abstract class Logger {
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, Object?>? context});
  void fatal(Object error, {StackTrace? stackTrace, Map<String, Object?>? context});
  void info(String message, {Map<String, Object?>? context});
  void identify(String userId);
  void clearUser();
}

extension NetworkAwareLogger on Logger {
  /// Logs [err] at error severity, unless it looks like a transient network
  /// failure (see [isTransientNetworkError]) — those log at info severity
  /// instead, so a routine connectivity blip isn't reported as an
  /// unresolved production error.
  void logPossibleNetworkError(
    String message,
    Object err, {
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    if (isTransientNetworkError(err)) {
      info('$message (transient network error)', context: {...?context, 'error': err.toString()});
    } else {
      error(message, error: err, stackTrace: stackTrace, context: context);
    }
  }
}
