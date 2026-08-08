import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/helpers/helpers.dart';

void main() {
  group('isTransientError', () {
    test('treats a TimeoutException as transient', () {
      expect(isTransientError(TimeoutException('after 30s')), isTrue);
    });

    test('treats a Postgrest gateway timeout (504) as transient', () {
      expect(
        isTransientError(PostgrestException(message: '', code: '504', details: 'Gateway Timeout')),
        isTrue,
      );
    });

    test('treats a Postgrest statement timeout (57014) as transient', () {
      expect(
        isTransientError(
          PostgrestException(
            message: 'canceling statement due to statement timeout',
            code: '57014',
            details: 'Internal Server Error',
          ),
        ),
        isTrue,
      );
    });

    test('treats a dropped connection as transient', () {
      expect(
        isTransientError(Exception('ClientException: Connection closed while receiving data')),
        isTrue,
      );
    });

    test('treats a Firebase network-request-failed error as transient', () {
      expect(isTransientError(Exception('[firebase_auth/network-request-failed] A network error occurred.')), isTrue);
    });

    test('does not treat a genuine Postgrest rejection as transient', () {
      expect(
        isTransientError(
          PostgrestException(
            message: 'duplicate key value violates unique constraint',
            code: '23505',
            details: 'Conflict',
          ),
        ),
        isFalse,
      );
    });

    test('does not treat an unrelated error as transient', () {
      expect(isTransientError(StateError('bad state')), isFalse);
    });
  });

  group('withTransientRetry', () {
    test('returns the result on first success without retrying', () async {
      var calls = 0;
      final result = await withTransientRetry(() async {
        calls++;
        return 'ok';
      }, delay: Duration.zero);

      expect(result, 'ok');
      expect(calls, 1);
    });

    test('retries a transient error and eventually succeeds', () async {
      var calls = 0;
      final result = await withTransientRetry(() async {
        calls++;
        if (calls < 3) throw TimeoutException('boom');
        return 'ok';
      }, delay: Duration.zero);

      expect(result, 'ok');
      expect(calls, 3);
    });

    test('rethrows immediately on a non-transient error without retrying', () async {
      var calls = 0;
      expect(
        () => withTransientRetry(() async {
          calls++;
          throw StateError('nope');
        }, delay: Duration.zero),
        throwsA(isA<StateError>()),
      );
      await Future.delayed(Duration.zero);
      expect(calls, 1);
    });

    test('rethrows once maxAttempts is exhausted', () async {
      var calls = 0;
      await expectLater(
        () => withTransientRetry(() async {
          calls++;
          throw TimeoutException('boom');
        }, maxAttempts: 2, delay: Duration.zero),
        throwsA(isA<TimeoutException>()),
      );
      expect(calls, 2);
    });
  });
}
