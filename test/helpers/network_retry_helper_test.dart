import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show ClientException;
import 'package:two_eight_two/helpers/helpers.dart';

void main() {
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
