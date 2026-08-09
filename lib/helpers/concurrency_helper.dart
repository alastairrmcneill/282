Future<List<T>> mapWithConcurrency<S, T>(
  List<S> items,
  int concurrency,
  Future<T> Function(S item) task,
) async {
  final results = List<T?>.filled(items.length, null);
  Object? error;
  StackTrace? errorStackTrace;
  var nextIndex = 0;

  Future<void> worker() async {
    while (true) {
      if (error != null) return;
      final index = nextIndex;
      if (index >= items.length) return;
      nextIndex++;

      try {
        results[index] = await task(items[index]);
      } catch (e, stackTrace) {
        error ??= e;
        errorStackTrace ??= stackTrace;
        return;
      }
    }
  }

  await Future.wait(List.generate(concurrency.clamp(1, items.isEmpty ? 1 : items.length), (_) => worker()));

  if (error != null) {
    Error.throwWithStackTrace(error!, errorStackTrace!);
  }

  return results.cast<T>();
}
