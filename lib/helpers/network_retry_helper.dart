import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;

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
