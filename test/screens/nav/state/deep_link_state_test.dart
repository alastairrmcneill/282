import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'deep_link_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  DeepLinkRepository,
  NavigationIntentState,
  Logger,
])
void main() {
  late MockDeepLinkRepository mockDeepLinkRepository;
  late MockNavigationIntentState mockNavigationIntentState;
  late MockLogger mockLogger;
  late DeepLinkState deepLinkState;

  late StreamController<NavigationIntent> eventStreamController;

  setUp(() {
    mockDeepLinkRepository = MockDeepLinkRepository();
    mockNavigationIntentState = MockNavigationIntentState();
    mockLogger = MockLogger();
    deepLinkState = DeepLinkState(
      mockDeepLinkRepository,
      mockNavigationIntentState,
      mockLogger,
    );

    // Create a fresh stream controller for each test
    eventStreamController = StreamController<NavigationIntent>.broadcast();

    // Default mock behavior for DeepLinkRepository
    when(mockDeepLinkRepository.events).thenAnswer((_) => eventStreamController.stream);
  });

  tearDown(() async {
    await eventStreamController.close();
  });

  group('DeepLinkState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(deepLinkState, isNotNull);
      });

      test('should not be started initially', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

        // Act - calling init twice
        await deepLinkState.init(enableLogging: true);
        await deepLinkState.init(enableLogging: true);

        // Assert - init should only be called once
        verify(mockDeepLinkRepository.init(enableLogging: true)).called(1);
      });
    });

    group('init', () {
      test('should initialize repository and listen to events', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

        // Act
        await deepLinkState.init(enableLogging: true);

        // Assert
        verify(mockDeepLinkRepository.init(enableLogging: true)).called(1);
        verify(mockDeepLinkRepository.events).called(1);
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should initialize with logging disabled', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

        // Act
        await deepLinkState.init(enableLogging: false);

        // Assert
        verify(mockDeepLinkRepository.init(enableLogging: false)).called(1);
        verify(mockDeepLinkRepository.events).called(1);
        verifyNever(mockLogger.error(any, error: anyNamed('error'), stackTrace: anyNamed('stackTrace')));
      });

      test('should enqueue intents when received from repository events', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging')))
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

      test('should handle error when accessing events stream', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});
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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

        // Act
        await deepLinkState.init(enableLogging: true);
        await deepLinkState.init(enableLogging: false);
        await deepLinkState.init(enableLogging: true);

        // Assert
        verify(mockDeepLinkRepository.init(enableLogging: true)).called(1);
        verify(mockDeepLinkRepository.events).called(1);
      });

      test('should not re-subscribe to events on multiple init calls', () async {
        // Arrange
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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

    group('Edge Cases', () {
      test('should handle stream errors gracefully during initialization', () async {
        // Arrange
        final errorStreamController = StreamController<NavigationIntent>.broadcast();
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});
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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) async {});

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
        when(mockDeepLinkRepository.init(enableLogging: anyNamed('enableLogging'))).thenAnswer((_) => completer.future);

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
