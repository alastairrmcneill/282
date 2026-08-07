import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:two_eight_two/helpers/network_error_helper.dart';

void main() {
  group('isTransientNetworkError', () {
    test('returns true for SocketException', () {
      expect(isTransientNetworkError(const SocketException('Failed host lookup')), isTrue);
    });

    test('returns true for HandshakeException', () {
      expect(isTransientNetworkError(const HandshakeException('Connection terminated during handshake')), isTrue);
    });

    test('returns true for TimeoutException', () {
      expect(isTransientNetworkError(TimeoutException('timed out')), isTrue);
    });

    test('returns true for a ClientException-style message', () {
      expect(
        isTransientNetworkError(
          Exception(
            "ClientException with SocketException: Failed host lookup: 'bzzdszqqstspbzyclwxh.supabase.co'",
          ),
        ),
        isTrue,
      );
    });

    test('returns true for a firebase_auth network-request-failed message', () {
      expect(
        isTransientNetworkError(
          Exception('[firebase_auth/unknown] An internal error has occurred. [ connection closed'),
        ),
        isTrue,
      );
    });

    test('returns true for an OSError-style DNS failure message', () {
      expect(
        isTransientNetworkError(
          Exception('OSError: OS Error: nodename nor servname provided, or not known, errno = 8'),
        ),
        isTrue,
      );
    });

    test('returns false for an unrelated application error', () {
      expect(isTransientNetworkError(StateError('Image compression failed (returned null).')), isFalse);
    });

    test('returns false for a genuine PostgrestException payload error', () {
      expect(
        isTransientNetworkError(
          Exception('PostgrestException(message: invalid input syntax for type uuid: "", code: 22P02)'),
        ),
        isFalse,
      );
    });
  });
}
