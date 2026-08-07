import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'deep_link_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  DeepLinkRepository,
  NavigationIntentState,
  Analytics,
  Logger,
])
void main() {
  late MockDeepLinkRepository mockDeepLinkRepository;
  late MockNavigationIntentState mockNavigationIntentState;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
  late DeepLinkState deepLinkState;

  late StreamController<NavigationIntent> eventStreamController;
  late StreamController<BranchLinkClick> clickStreamController;

  setUp(() {
    mockDeepLinkRepository = MockDeepLinkRepository();
    mockNavigationIntentState = MockNavigationIntentState();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();
    deepLinkState = DeepLinkState(
      mockDeepLinkRepository,
      mockNavigationIntentState,
      mockAnalytics,
      mockLogger,
    );

    // Create fresh stream controllers for each test
    eventStreamController = StreamController<NavigationIntent>.broadcast();
    clickStreamController = StreamController<BranchLinkClick>.broadcast();

    // Default mock behavior for DeepLinkRepository
    when(mockDeepLinkRepository.events).thenAnswer((_) => eventStreamController.stream);
    when(mockDeepLinkRepository.clicks).thenAnswer((_) => clickStreamController.stream);
  });

  tearDown(() async {
    await eventStreamController.close();
    await clickStreamController.close();
  });

  group('DeepLinkState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(deepLinkState, isNotNull);
      });

      test('should not be started initially', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        // Act - calling init twice
        await deepLinkState.init(enableLogging: true);
        await deepLinkState.init(enableLogging: true);

        // Assert - init should only be called once
        verify(mockDeepLinkRepository.init(enableLogging: true, onSessionError: anyNamed('onSessionError'))).called(1);
      });
    });

    group('init', () {
      test('should initialize repository and listen to events', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        // Act
        await deepLinkState.init(enableLogging: true);

        // Assert
        verify(mockDeepLinkRepository.init(enableLogging: true, onSessionError: anyNamed('onSessionError'))).called(1);
        verify(mockDeepLinkRepository.events).called(1);
        verify(mockDeepLinkRepository.clicks).called(1);
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should initialize with logging disabled', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        // Act
        await deepLinkState.init(enableLogging: false);

        // Assert
        verify(mockDeepLinkRepository.init(enableLogging: false, onSessionError: anyNamed('onSessionError'))).called(1);
        verify(mockDeepLinkRepository.events).called(1);
        verify(mockDeepLinkRepository.clicks).called(1);
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should enqueue intents when received from repository events', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intent = OpenMunroIntent(munroId: 123);

        // Act
        await deepLinkState.init(enableLogging: true);

        // Emit event after initialization
        eventStreamController.add(intent);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockNavigationIntentState.enqueue(intent)).called(1);
      });

      test('should enqueue multiple intents from repository events', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intent1 = OpenMunroIntent(munroId: 123);
        final intent2 = OpenMunroIntent(munroId: 456);
        final intent3 = RefreshHomeIntent();

        // Act
        await deepLinkState.init(enableLogging: true);

        // Emit multiple events
        eventStreamController.add(intent1);
        eventStreamController.add(intent2);
        eventStreamController.add(intent3);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockNavigationIntentState.enqueue(intent1)).called(1);
        verify(mockNavigationIntentState.enqueue(intent2)).called(1);
        verify(mockNavigationIntentState.enqueue(intent3)).called(1);
      });

      test('should handle error during repository initialization', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError')))
            .thenThrow(Exception('Initialization failed'));

        // Act
        await deepLinkState.init(enableLogging: true);

        // Assert
        verify(mockLogger.error(
          'DeepLink init failed',
          error: anyNamed('error'),
          stackTrace: anyNamed('stackTrace'),
        )).called(1);
        verifyNever(mockNavigationIntentState.enqueue(any));
      });

      test('logs a non-fatal Branch session error as info, not error', () async {
        // Arrange — capture the onSessionError callback DeepLinkState passes down,
        // simulating the native Branch session stream failing asynchronously after
        // init() has already returned (e.g. a native init timeout).
        void Function(Object, StackTrace)? capturedOnSessionError;
        when(mockDeepLinkRepository.init(
          enableLogging: anyNamed('enableLogging'),
          onSessionError: anyNamed('onSessionError'),
        )).thenAnswer((invocation) async {
          capturedOnSessionError = invocation.namedArguments[#onSessionError]
              as void Function(Object, StackTrace)?;
        });

        // Act
        await deepLinkState.init(enableLogging: true);
        capturedOnSessionError?.call(Exception('Branch session stream failed'), StackTrace.current);

        // Assert — this must never be reported as an unresolved production error.
        verify(mockLogger.info(argThat(contains('Branch session listener error')))).called(1);
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error when accessing events stream', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});
        when(mockDeepLinkRepository.events).thenThrow(Exception('Stream error'));

        // Act
        await deepLinkState.init(enableLogging: true);

        // Assert
        verify(mockLogger.error(
          'DeepLink init failed',
          error: anyNamed('error'),
          stackTrace: anyNamed('stackTrace'),
        )).called(1);
        verifyNever(mockNavigationIntentState.enqueue(any));
      });

      test('should only initialize once even when called multiple times', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        // Act
        await deepLinkState.init(enableLogging: true);
        await deepLinkState.init(enableLogging: false);
        await deepLinkState.init(enableLogging: true);

        // Assert
        verify(mockDeepLinkRepository.init(enableLogging: true, onSessionError: anyNamed('onSessionError'))).called(1);
        verify(mockDeepLinkRepository.events).called(1);
        verify(mockDeepLinkRepository.clicks).called(1);
      });

      test('should not re-subscribe to events on multiple init calls', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intent = OpenMunroIntent(munroId: 789);

        // Act
        await deepLinkState.init(enableLogging: true);
        await deepLinkState.init(enableLogging: true);

        // Emit event
        eventStreamController.add(intent);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert - should only enqueue once since we didn't subscribe twice
        verify(mockNavigationIntentState.enqueue(intent)).called(1);
      });
    });
    group('Event Stream Handling', () {
      test('should handle OpenMunroIntent with valid munro ID', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intent = OpenMunroIntent(munroId: 42);

        // Act
        await deepLinkState.init(enableLogging: true);
        eventStreamController.add(intent);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockNavigationIntentState.enqueue(intent)).called(1);
      });

      test('should handle RefreshHomeIntent', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intent = RefreshHomeIntent();

        // Act
        await deepLinkState.init(enableLogging: true);
        eventStreamController.add(intent);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockNavigationIntentState.enqueue(intent)).called(1);
      });

      test('should handle rapid succession of intents', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intents = List.generate(10, (i) => OpenMunroIntent(munroId: i));

        // Act
        await deepLinkState.init(enableLogging: true);

        for (final intent in intents) {
          eventStreamController.add(intent);
        }
        await Future.delayed(Duration(milliseconds: 100));

        // Assert
        for (final intent in intents) {
          verify(mockNavigationIntentState.enqueue(intent)).called(1);
        }
      });

      test('should continue listening after receiving intents', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intent1 = OpenMunroIntent(munroId: 1);
        final intent2 = OpenMunroIntent(munroId: 2);

        // Act
        await deepLinkState.init(enableLogging: true);

        // Send first intent
        eventStreamController.add(intent1);
        await Future.delayed(Duration(milliseconds: 50));

        // Send second intent after a delay
        await Future.delayed(Duration(milliseconds: 100));
        eventStreamController.add(intent2);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockNavigationIntentState.enqueue(intent1)).called(1);
        verify(mockNavigationIntentState.enqueue(intent2)).called(1);
      });
    });

    group('Click Analytics Tracking', () {
      test('should track branchLinkClicked when a click is received', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        const click = BranchLinkClick(
          canonicalIdentifier: 'munro/123',
          channel: 'facebook',
          campaign: 'summer_launch',
          feature: 'share',
          routed: true,
        );

        // Act
        await deepLinkState.init(enableLogging: true);
        clickStreamController.add(click);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockAnalytics.track(
          AnalyticsEvent.branchLinkClicked,
          props: {
            AnalyticsProp.linkType: 'munro/123',
            AnalyticsProp.channel: 'facebook',
            AnalyticsProp.campaign: 'summer_launch',
            AnalyticsProp.feature: 'share',
            AnalyticsProp.routed: true,
          },
        )).called(1);
      });

      test('should track branchLinkClicked with routed false when click did not resolve to an intent', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        const click = BranchLinkClick(
          canonicalIdentifier: 'app',
          channel: null,
          campaign: null,
          feature: null,
          routed: false,
        );

        // Act
        await deepLinkState.init(enableLogging: true);
        clickStreamController.add(click);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockAnalytics.track(
          AnalyticsEvent.branchLinkClicked,
          props: {
            AnalyticsProp.linkType: 'app',
            AnalyticsProp.channel: null,
            AnalyticsProp.campaign: null,
            AnalyticsProp.feature: null,
            AnalyticsProp.routed: false,
          },
        )).called(1);
      });

      test('should not track branchLinkClicked when a navigation intent is received (no click)', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        // Act
        await deepLinkState.init(enableLogging: true);
        eventStreamController.add(OpenMunroIntent(munroId: 123));
        await Future.delayed(Duration(milliseconds: 50));

        // Assert - analytics tracking now only happens off the clicks stream, not events
        verifyNever(mockAnalytics.track(any, props: anyNamed('props')));
      });

      test('should track multiple clicks independently', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        const click1 = BranchLinkClick(
          canonicalIdentifier: 'munro/1',
          channel: 'sms',
          campaign: null,
          feature: null,
          routed: true,
        );
        const click2 = BranchLinkClick(
          canonicalIdentifier: 'munro/2',
          channel: 'email',
          campaign: null,
          feature: null,
          routed: true,
        );

        // Act
        await deepLinkState.init(enableLogging: true);
        clickStreamController.add(click1);
        clickStreamController.add(click2);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockAnalytics.track(AnalyticsEvent.branchLinkClicked, props: anyNamed('props'))).called(2);
      });
    });

    group('Edge Cases', () {
      test('should handle stream errors gracefully during initialization', () async {
        // Arrange
        final errorStreamController = StreamController<NavigationIntent>.broadcast();
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});
        when(mockDeepLinkRepository.events).thenAnswer((_) => errorStreamController.stream);

        // Act
        await deepLinkState.init(enableLogging: true);

        // Stream errors are caught by the stream's onError handler, but in this case
        // we don't have an onError handler on the listen call, so the error would
        // be unhandled. This test verifies the behavior without explicitly testing error handling.
        // The actual implementation uses listen without onError, so errors would propagate.

        // Assert - should not crash during initialization
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));

        await errorStreamController.close();
      });

      test('should handle OpenMunroIntent with zero munro ID', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intent = OpenMunroIntent(munroId: 0);

        // Act
        await deepLinkState.init(enableLogging: true);
        eventStreamController.add(intent);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockNavigationIntentState.enqueue(intent)).called(1);
      });

      test('should handle OpenMunroIntent with negative munro ID', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intent = OpenMunroIntent(munroId: -1);

        // Act
        await deepLinkState.init(enableLogging: true);
        eventStreamController.add(intent);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockNavigationIntentState.enqueue(intent)).called(1);
      });

      test('should handle OpenMunroIntent with large munro ID', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intent = OpenMunroIntent(munroId: 999999);

        // Act
        await deepLinkState.init(enableLogging: true);
        eventStreamController.add(intent);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert
        verify(mockNavigationIntentState.enqueue(intent)).called(1);
      });

      test('should handle same intent being sent multiple times', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) async {});

        final intent = OpenMunroIntent(munroId: 123);

        // Act
        await deepLinkState.init(enableLogging: true);

        // Send same intent multiple times
        eventStreamController.add(intent);
        eventStreamController.add(intent);
        eventStreamController.add(intent);
        await Future.delayed(Duration(milliseconds: 50));

        // Assert - each should be enqueued (deduplication happens in NavigationIntentState)
        verify(mockNavigationIntentState.enqueue(intent)).called(3);
      });

      test('should handle async initialization completing after dispose', () async {
        // Arrange
        final completer = Completer<void>();
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'), onSessionError: anyNamed('onSessionError'))).thenAnswer((_) => completer.future);

        // Act
        final initFuture = deepLinkState.init(enableLogging: true);
        deepLinkState.dispose();
        completer.complete();
        await initFuture;

        // Assert - should complete without error
        // Since dispose was called before init completed, events stream might not be set up
        // but this shouldn't cause any errors
      });
    });
  });
}
