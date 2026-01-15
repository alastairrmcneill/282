import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'share_munro_state_test.mocks.dart';

@GenerateMocks([
  ShareLinkRepository,
  Analytics,
  Logger,
])
void main() {
  late MockShareLinkRepository mockShareLinkRepository;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
  late ShareMunroState shareMunroState;

  setUp(() {
    mockShareLinkRepository = MockShareLinkRepository();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();

    when(mockAnalytics.track(any, props: anyNamed('props'))).thenAnswer((_) async {});

    shareMunroState = ShareMunroState(
      mockShareLinkRepository,
      mockAnalytics,
      mockLogger,
    );

    shareMunroState.reset();
  });

  group('ShareMunroState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(shareMunroState.status, ShareMunroStatus.initial);
        expect(shareMunroState.error, isA<Error>());
        expect(shareMunroState.error.code, isEmpty);
        expect(shareMunroState.error.message, isEmpty);
      });
    });

    group('createShareLink', () {
      test('should track analytics with munro props and return link on success', () async {
        // Arrange
        when(mockShareLinkRepository.createMunroLink(any)).thenAnswer((_) async => 'https://ex.am/ple');

        // Act
        final link = await shareMunroState.createShareLink(munroId: 42, munroName: 'Ben Test');

        // Assert
        expect(link, 'https://ex.am/ple');
        expect(shareMunroState.status, ShareMunroStatus.initial);

        verify(mockAnalytics.track(
          AnalyticsEvent.munroShared,
          props: {
            AnalyticsProp.munroId: 42,
            AnalyticsProp.munroName: 'Ben Test',
          },
        )).called(1);

        verify(mockShareLinkRepository.createMunroLink(42)).called(1);
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should log and return null when repository throws', () async {
        // Arrange
        final exception = Exception('Branch down');
        when(mockShareLinkRepository.createMunroLink(any)).thenThrow(exception);

        // Act
        final link = await shareMunroState.createShareLink(munroId: 1, munroName: 'Ben Error');

        // Assert
        expect(link, isNull);

        verify(mockAnalytics.track(
          AnalyticsEvent.munroShared,
          props: {
            AnalyticsProp.munroId: 1,
            AnalyticsProp.munroName: 'Ben Error',
          },
        )).called(1);

        verify(mockShareLinkRepository.createMunroLink(1)).called(1);
        verify(mockLogger.error(
          'Failed to create share link',
          error: exception,
          stackTrace: anyNamed('stackTrace'),
        )).called(1);
      });

      test('should log and return null when analytics throws (and not call repository)', () async {
        // Arrange
        final exception = Exception('Analytics down');
        when(mockAnalytics.track(any, props: anyNamed('props'))).thenThrow(exception);

        // Act
        final link = await shareMunroState.createShareLink(munroId: 99, munroName: 'Ben TrackFail');

        // Assert
        expect(link, isNull);
        verifyNever(mockShareLinkRepository.createMunroLink(any));
        verify(mockLogger.error(
          'Failed to create share link',
          error: exception,
          stackTrace: anyNamed('stackTrace'),
        )).called(1);
      });
    });

    group('setters', () {
      test('setStatus should set status and notify listeners', () {
        // Arrange
        var notifications = 0;
        shareMunroState.addListener(() => notifications++);

        // Act
        shareMunroState.setStatus = ShareMunroStatus.loaded;

        // Assert
        expect(shareMunroState.status, ShareMunroStatus.loaded);
        expect(notifications, 1);
      });

      test('setError should set error status, set error, log message, and notify listeners', () {
        // Arrange
        var notifications = 0;
        shareMunroState.addListener(() => notifications++);
        final error = Error(code: 'share_failed', message: 'No link for you');

        // Act
        shareMunroState.setError = error;

        // Assert
        expect(shareMunroState.status, ShareMunroStatus.error);
        expect(shareMunroState.error.message, 'No link for you');
        verify(mockLogger.error('No link for you')).called(1);
        expect(notifications, 1);
      });
    });

    group('logError', () {
      test('should log exception and stack trace without notifying listeners', () {
        // Arrange
        var notifications = 0;
        shareMunroState.addListener(() => notifications++);
        final exception = Exception('Boom');
        final stackTrace = StackTrace.current;

        // Act
        shareMunroState.logError(exception, stackTrace);

        // Assert
        verify(mockLogger.error(exception.toString(), stackTrace: stackTrace)).called(1);
        expect(notifications, 0);
      });
    });

    group('reset', () {
      test('should reset status + error and notify listeners', () {
        // Arrange
        shareMunroState.setStatus = ShareMunroStatus.loaded;
        shareMunroState.setError = Error(code: 'x', message: 'y');

        var notifications = 0;
        shareMunroState.addListener(() => notifications++);

        // Act
        shareMunroState.reset();

        // Assert
        expect(shareMunroState.status, ShareMunroStatus.initial);
        expect(shareMunroState.error.code, isEmpty);
        expect(shareMunroState.error.message, isEmpty);
        expect(notifications, 1);
      });
    });
  });
}
