import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show ClientException;
import 'package:two_eight_two/helpers/helpers.dart';

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

    test('returns true for OSError', () {
      expect(isTransientNetworkError(const OSError('Bad file descriptor', 9)), isTrue);
    });

    test('returns true for a ClientException from package:http', () {
      expect(isTransientNetworkError(ClientException('Connection closed while receiving data')), isTrue);
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

    test('returns true for a blocking Cloud Function deadline-exceeded message', () {
      expect(
        isTransientNetworkError(
          Exception('[firebase_auth/blocking-cloud-function-returned-error] Cloud function deadline exceeded.'),
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

  group('withNetworkRetry', () {
    test('returns the result on first success without retrying', () async {
      var calls = 0;
      final result = await withNetworkRetry(() async {
        calls++;
        return 'ok';
      });

      expect(result, 'ok');
      expect(calls, 1);
    });

    test('retries a transient SocketException and succeeds', () async {
      var calls = 0;
      final result = await withNetworkRetry(
        () async {
          calls++;
          if (calls == 1) {
            throw const SocketException('Bad file descriptor');
          }
          return 'ok';
        },
        delay: Duration.zero,
      );

      expect(result, 'ok');
      expect(calls, 2);
    });

    test('retries an OSError up to the retry limit then rethrows', () async {
      var calls = 0;
      await expectLater(
        () => withNetworkRetry<void>(
          () async {
            calls++;
            throw const OSError('Bad file descriptor', 9);
          },
          retries: 2,
          delay: Duration.zero,
        ),
        throwsA(isA<OSError>()),
      );

      expect(calls, 3); // initial attempt + 2 retries
    });

    test('retries a ClientException from package:http', () async {
      var calls = 0;
      final result = await withNetworkRetry(
        () async {
          calls++;
          if (calls == 1) {
            throw ClientException('Connection closed while receiving data');
          }
          return 'ok';
        },
        delay: Duration.zero,
      );

      expect(result, 'ok');
      expect(calls, 2);
    });

    test('does not retry a non-transient error', () async {
      var calls = 0;
      await expectLater(
        () => withNetworkRetry<void>(
          () async {
            calls++;
            throw ArgumentError('not a network problem');
          },
          delay: Duration.zero,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(calls, 1);
    });

    test('gives up after exhausting retries', () async {
      var calls = 0;
      await expectLater(
        () => withNetworkRetry<void>(
          () async {
            calls++;
            throw const SocketException('still offline');
          },
          retries: 3,
          delay: Duration.zero,
        ),
        throwsA(isA<SocketException>()),
      );

      expect(calls, 4); // initial attempt + 3 retries
    });
  });
}
