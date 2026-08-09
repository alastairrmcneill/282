import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;

bool isTransientNetworkError(Object error) {
  if (error is SocketException ||
      error is OSError ||
      error is HandshakeException ||
      error is TimeoutException ||
      error is HttpException ||
      error is ClientException) {
    return true;
  }

  final message = error.toString().toLowerCase();
  const transientMarkers = [
    'clientexception',
    'socketexception',
    'handshakeexception',
    'connection closed',
    'connection reset',
    'connection terminated',
    'connection refused',
    'failed host lookup',
    'network-request-failed',
    'network error',
    'operation timed out',
    'software caused connection abort',
    "can't assign requested address",
    'nodename nor servname provided',
    'no address associated with hostname',
  ];

  return transientMarkers.any(message.contains);
}

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
      if (attempt >= retries || !isTransientNetworkError(error)) rethrow;
      attempt++;
      await Future.delayed(delay * attempt);
    }
  }
}
