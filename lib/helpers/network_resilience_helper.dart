import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// A dropped connection, DNS blip, or backend gateway/statement timeout that
/// a retry (or the next pull-to-refresh) would silently recover from — as
/// opposed to a genuine bug or a permanent failure.
bool isTransientError(Object error) {
  if (error is TimeoutException) return true;

  if (error is PostgrestException) {
    const transientCodes = {'504', '57014'};
    if (transientCodes.contains(error.code)) return true;
  }

  final message = error.toString().toLowerCase();
  const transientMarkers = [
    'socketexception',
    'clientexception',
    'handshakeexception',
    'connection closed',
    'connection reset',
    'connection terminated',
    'connection refused',
    'operation timed out',
    'gateway timeout',
    'statement timeout',
    "can't assign requested address",
    'failed host lookup',
    'software caused connection abort',
    'network-request-failed',
  ];
  return transientMarkers.any(message.contains);
}

/// Retries [action] with a short linear backoff when it fails with a
/// transient error; a genuine error (a real API rejection, a programming
/// error) is rethrown immediately on the first attempt.
Future<T> withTransientRetry<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
  Duration delay = const Duration(milliseconds: 500),
}) async {
  for (var attempt = 1; ; attempt++) {
    try {
      return await action();
    } catch (error) {
      if (attempt >= maxAttempts || !isTransientError(error)) rethrow;
      await Future.delayed(delay * attempt);
    }
  }
}
