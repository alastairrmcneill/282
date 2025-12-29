abstract class Logger {
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, Object?>? context});
  void fatal(Object error, {StackTrace? stackTrace, Map<String, Object?>? context});
  void info(String message, {Map<String, Object?>? context});
}
