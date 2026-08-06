import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;

/// Retries [action] when it fails with a transient, connection-level error —
/// the kind that shows up as OSError/SocketException/HandshakeException/
/// ClientException/TimeoutException from the underlying HTTP client, most
/// commonly right after the app resumes from the background and reuses a
/// socket the OS has already torn down. Anything else (e.g. a Postgrest
/// error response, a programming error) is rethrown immediately.
///
/// Uses a short, fixed number of retries with a small linear backoff — this
/// is meant to smooth over a single flaky reconnect, not to paper over a
/// genuinely unreachable server.
Future<T> withNetworkRetry<T>(
  Future<T> Function() action, {
  int retries = 2,
  Duration delay = const Duration(milliseconds: 400),
}) async {
  var attempt = 0;
  while (true) {
    try {
      return await action();
    } catch (error) {
      if (attempt >= retries || !_isTransientNetworkError(error)) rethrow;
      attempt++;
      await Future.delayed(delay * attempt);
    }
  }
}

bool _isTransientNetworkError(Object error) {
  return error is SocketException ||
      error is OSError ||
      error is HandshakeException ||
      error is TimeoutException ||
      error is ClientException;
}
