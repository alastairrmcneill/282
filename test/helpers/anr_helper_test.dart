import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:two_eight_two/helpers/helpers.dart';

SentryEvent _anrEvent({
  required bool? inForeground,
  required bool hasFirstPartyFrame,
}) {
  return SentryEvent(
    contexts: Contexts(app: SentryApp(inForeground: inForeground)),
    exceptions: [
      SentryException(
        type: 'ApplicationNotResponding',
        value: 'ApplicationNotResponding: Background ANR',
        mechanism: Mechanism(type: 'AppExitInfo'),
        stackTrace: SentryStackTrace(
          frames: [
            SentryStackFrame(function: 'android.os.MessageQueue.next', inApp: false),
            if (hasFirstPartyFrame) SentryStackFrame(function: 'MyRepository.fetchThings', inApp: true),
          ],
        ),
      ),
    ],
  );
}

void main() {
  group('isNoisyBackgroundAnr', () {
    test('returns true for a background ANR with only system frames', () {
      expect(isNoisyBackgroundAnr(_anrEvent(inForeground: false, hasFirstPartyFrame: false)), isTrue);
    });

    test('returns false when the app was in the foreground', () {
      expect(isNoisyBackgroundAnr(_anrEvent(inForeground: true, hasFirstPartyFrame: false)), isFalse);
    });

    test('returns false when foreground state is unknown', () {
      expect(isNoisyBackgroundAnr(_anrEvent(inForeground: null, hasFirstPartyFrame: false)), isFalse);
    });

    test('returns false when a first-party frame is present', () {
      expect(isNoisyBackgroundAnr(_anrEvent(inForeground: false, hasFirstPartyFrame: true)), isFalse);
    });

    test('returns false for a non-ANR exception', () {
      final event = SentryEvent(
        contexts: Contexts(app: SentryApp(inForeground: false)),
        exceptions: [
          SentryException(
            type: 'StateError',
            value: 'Bad state',
            mechanism: Mechanism(type: 'generic'),
          ),
        ],
      );

      expect(isNoisyBackgroundAnr(event), isFalse);
    });

    test('returns false when there are no exceptions', () {
      expect(isNoisyBackgroundAnr(SentryEvent()), isFalse);
    });
  });
}
