import 'dart:async';
import 'dart:io';

/// Returns true if [error] looks like a transient network failure — a
/// dropped connection, DNS hiccup, TLS handshake failure, or timeout — as
/// opposed to a genuine application bug.
///
/// These conditions are outside the app's control (poor signal, a flaky
/// public wifi hotspot, a brief DNS blip) and normally resolve themselves on
/// the next attempt, so callers should log them at a lower severity instead
/// of reporting them as unresolved production errors.
bool isTransientNetworkError(Object error) {
  if (error is SocketException ||
      error is HandshakeException ||
      error is TimeoutException ||
      error is HttpException) {
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
