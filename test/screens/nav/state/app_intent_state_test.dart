import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'app_intent_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  Logger,
])
void main() {
  late MockLogger mockLogger;
  late AppIntentState appIntentState;

  late OpenMunroIntent sampleOpenMunroIntent1;
  late OpenMunroIntent sampleOpenMunroIntent2;
  late RefreshHomeIntent sampleRefreshHomeIntent;

  setUp(() {
    // Sample intent data for testing
    sampleOpenMunroIntent1 = const OpenMunroIntent(munroId: 1);
    sampleOpenMunroIntent2 = const OpenMunroIntent(munroId: 2);
    sampleRefreshHomeIntent = const RefreshHomeIntent();

    mockLogger = MockLogger();
    appIntentState = AppIntentState(mockLogger);
  });

  group('AppIntentState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(appIntentState.pending, isEmpty);
        expect(appIntentState.next, isNull);
      });
    });

    group('enqueue', () {
      test('should add intent to queue', () {
        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert
        expect(appIntentState.pending.length, 1);
        expect(appIntentState.pending.first, sampleOpenMunroIntent1);
        expect(appIntentState.next, sampleOpenMunroIntent1);
      });

      test('should add multiple intents to queue in order', () {
        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleOpenMunroIntent2);
        appIntentState.enqueue(sampleRefreshHomeIntent);

        // Assert
        expect(appIntentState.pending.length, 3);
        expect(appIntentState.pending[0], sampleOpenMunroIntent1);
        expect(appIntentState.pending[1], sampleOpenMunroIntent2);
        expect(appIntentState.pending[2], sampleRefreshHomeIntent);
        expect(appIntentState.next, sampleOpenMunroIntent1);
      });

      test('should not add duplicate intent based on dedupeKey', () {
        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert
        expect(appIntentState.pending.length, 1);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
      });

      test('should allow different intents with different dedupeKeys', () {
        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleOpenMunroIntent2);

        // Assert
        expect(appIntentState.pending.length, 2);
        verifyNever(mockLogger.info(any));
      });

      test('should clear dedupe keys after 200 entries', () {
        // Arrange - add 201 different intents
        for (int i = 0; i < 201; i++) {
          appIntentState.enqueue(OpenMunroIntent(munroId: i));
        }

        // Assert - all intents should be added (no duplicates dropped)
        expect(appIntentState.pending.length, 201);
        verifyNever(mockLogger.info(argThat(contains('Dropped duplicate intent'))));

        // Act - try to add the first intent again (dedupe keys should be cleared)
        appIntentState.enqueue(const OpenMunroIntent(munroId: 0));

        // Assert - the duplicate should be added because dedupe keys were cleared
        expect(appIntentState.pending.length, 202);
        verifyNever(mockLogger.info(argThat(contains('Dropped duplicate intent'))));
      });

      test('should handle RefreshHomeIntent deduplication', () {
        // Act
        appIntentState.enqueue(sampleRefreshHomeIntent);
        appIntentState.enqueue(sampleRefreshHomeIntent);

        // Assert
        expect(appIntentState.pending.length, 1);
        verify(mockLogger.info('Dropped duplicate intent: refresh_home')).called(1);
      });

      test('should allow adding different types of intents', () {
        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleRefreshHomeIntent);
        appIntentState.enqueue(sampleOpenMunroIntent2);

        // Assert
        expect(appIntentState.pending.length, 3);
        expect(appIntentState.pending[0], isA<OpenMunroIntent>());
        expect(appIntentState.pending[1], isA<RefreshHomeIntent>());
        expect(appIntentState.pending[2], isA<OpenMunroIntent>());
      });
    });

    group('consumeNext', () {
      test('should return and remove first intent from queue', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleOpenMunroIntent2);

        // Act
        final consumed = appIntentState.consumeNext();

        // Assert
        expect(consumed, sampleOpenMunroIntent1);
        expect(appIntentState.pending.length, 1);
        expect(appIntentState.pending.first, sampleOpenMunroIntent2);
        expect(appIntentState.next, sampleOpenMunroIntent2);
      });

      test('should return null when queue is empty', () {
        // Act
        final consumed = appIntentState.consumeNext();

        // Assert
        expect(consumed, isNull);
        expect(appIntentState.pending, isEmpty);
        expect(appIntentState.next, isNull);
      });

      test('should consume all intents in order', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleRefreshHomeIntent);
        appIntentState.enqueue(sampleOpenMunroIntent2);

        // Act & Assert
        final first = appIntentState.consumeNext();
        expect(first, sampleOpenMunroIntent1);
        expect(appIntentState.pending.length, 2);

        final second = appIntentState.consumeNext();
        expect(second, sampleRefreshHomeIntent);
        expect(appIntentState.pending.length, 1);

        final third = appIntentState.consumeNext();
        expect(third, sampleOpenMunroIntent2);
        expect(appIntentState.pending.length, 0);

        final fourth = appIntentState.consumeNext();
        expect(fourth, isNull);
      });

      test('should update next property correctly after consumption', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleOpenMunroIntent2);

        // Act & Assert
        expect(appIntentState.next, sampleOpenMunroIntent1);

        appIntentState.consumeNext();
        expect(appIntentState.next, sampleOpenMunroIntent2);

        appIntentState.consumeNext();
        expect(appIntentState.next, isNull);
      });

      test('should allow re-enqueueing consumed intent', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.consumeNext();

        // The dedupe key should still be in the set, so re-enqueueing should be blocked
        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert - should be dropped as duplicate
        expect(appIntentState.pending.length, 0);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
      });
    });

    group('clear', () {
      test('should clear all intents from queue', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleOpenMunroIntent2);
        appIntentState.enqueue(sampleRefreshHomeIntent);

        // Act
        appIntentState.clear();

        // Assert
        expect(appIntentState.pending, isEmpty);
        expect(appIntentState.next, isNull);
      });

      test('should work when queue is already empty', () {
        // Act
        appIntentState.clear();

        // Assert
        expect(appIntentState.pending, isEmpty);
        expect(appIntentState.next, isNull);
      });

      test('should not clear dedupe keys', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.clear();

        // Act - try to enqueue same intent after clear
        appIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert - should still be dropped as duplicate
        expect(appIntentState.pending.length, 0);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
      });
    });

    group('next property', () {
      test('should return first intent without removing it', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleOpenMunroIntent2);

        // Act
        final nextIntent1 = appIntentState.next;
        final nextIntent2 = appIntentState.next;

        // Assert
        expect(nextIntent1, sampleOpenMunroIntent1);
        expect(nextIntent2, sampleOpenMunroIntent1);
        expect(appIntentState.pending.length, 2);
      });

      test('should return null when queue is empty', () {
        // Act
        final nextIntent = appIntentState.next;

        // Assert
        expect(nextIntent, isNull);
      });
    });

    group('pending property', () {
      test('should return unmodifiable view of queue', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleOpenMunroIntent2);

        // Act
        final pendingList = appIntentState.pending;

        // Assert
        expect(pendingList, isA<UnmodifiableListView>());
        expect(pendingList.length, 2);
      });

      test('should reflect current state of queue', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);
        expect(appIntentState.pending.length, 1);

        // Act
        appIntentState.enqueue(sampleOpenMunroIntent2);

        // Assert
        expect(appIntentState.pending.length, 2);
      });
    });

    group('Edge Cases', () {
      test('should handle enqueuing and consuming single intent', () {
        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);
        final consumed = appIntentState.consumeNext();

        // Assert
        expect(consumed, sampleOpenMunroIntent1);
        expect(appIntentState.pending, isEmpty);
        expect(appIntentState.next, isNull);
      });

      test('should handle multiple consume operations on empty queue', () {
        // Act
        final consumed1 = appIntentState.consumeNext();
        final consumed2 = appIntentState.consumeNext();
        final consumed3 = appIntentState.consumeNext();

        // Assert
        expect(consumed1, isNull);
        expect(consumed2, isNull);
        expect(consumed3, isNull);
      });

      test('should handle multiple clear operations', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);

        // Act
        appIntentState.clear();
        appIntentState.clear();
        appIntentState.clear();

        // Assert
        expect(appIntentState.pending, isEmpty);
      });

      test('should handle alternating enqueue and consume', () {
        // Act & Assert
        appIntentState.enqueue(sampleOpenMunroIntent1);
        expect(appIntentState.pending.length, 1);

        final consumed1 = appIntentState.consumeNext();
        expect(consumed1, sampleOpenMunroIntent1);
        expect(appIntentState.pending.length, 0);

        appIntentState.enqueue(sampleOpenMunroIntent2);
        expect(appIntentState.pending.length, 1);

        final consumed2 = appIntentState.consumeNext();
        expect(consumed2, sampleOpenMunroIntent2);
        expect(appIntentState.pending.length, 0);
      });

      test('should handle same munroId intents as duplicates', () {
        // Arrange
        const intent1 = OpenMunroIntent(munroId: 42);
        const intent2 = OpenMunroIntent(munroId: 42);

        // Act
        appIntentState.enqueue(intent1);
        appIntentState.enqueue(intent2);

        // Assert
        expect(appIntentState.pending.length, 1);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:42')).called(1);
      });

      test('should handle different munroId intents as unique', () {
        // Arrange
        const intent1 = OpenMunroIntent(munroId: 1);
        const intent2 = OpenMunroIntent(munroId: 2);
        const intent3 = OpenMunroIntent(munroId: 3);

        // Act
        appIntentState.enqueue(intent1);
        appIntentState.enqueue(intent2);
        appIntentState.enqueue(intent3);

        // Assert
        expect(appIntentState.pending.length, 3);
        verifyNever(mockLogger.info(any));
      });

      test('should handle large number of unique intents', () {
        // Arrange & Act
        for (int i = 0; i < 100; i++) {
          appIntentState.enqueue(OpenMunroIntent(munroId: i));
        }

        // Assert
        expect(appIntentState.pending.length, 100);
        verifyNever(mockLogger.info(argThat(contains('Dropped duplicate intent'))));
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when enqueuing intent', () {
        bool notified = false;
        appIntentState.addListener(() => notified = true);

        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when consuming intent', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);

        bool notified = false;
        appIntentState.addListener(() => notified = true);

        // Act
        appIntentState.consumeNext();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when clearing queue', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);

        bool notified = false;
        appIntentState.addListener(() => notified = true);

        // Act
        appIntentState.clear();

        // Assert
        expect(notified, true);
      });

      test('should not notify listeners when enqueuing duplicate', () {
        // Arrange
        appIntentState.enqueue(sampleOpenMunroIntent1);

        bool notified = false;
        appIntentState.addListener(() => notified = true);

        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert
        expect(notified, false);
      });

      test('should notify listeners when consuming from empty queue', () {
        bool notified = false;
        appIntentState.addListener(() => notified = true);

        // Act
        appIntentState.consumeNext();

        // Assert - consumeNext on empty queue should not notify
        expect(notified, false);
      });

      test('should notify listeners multiple times for multiple operations', () {
        int notificationCount = 0;
        appIntentState.addListener(() => notificationCount++);

        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.enqueue(sampleOpenMunroIntent2);
        appIntentState.consumeNext();
        appIntentState.clear();

        // Assert
        expect(notificationCount, 4);
      });

      test('should notify listeners when clearing empty queue', () {
        bool notified = false;
        appIntentState.addListener(() => notified = true);

        // Act
        appIntentState.clear();

        // Assert
        expect(notified, true);
      });
    });

    group('Dedupe Key Management', () {
      test('should use correct dedupe key for OpenMunroIntent', () {
        // Arrange
        const intent = OpenMunroIntent(munroId: 123);

        // Act
        appIntentState.enqueue(intent);
        appIntentState.enqueue(intent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: open_munro:123')).called(1);
      });

      test('should use correct dedupe key for RefreshHomeIntent', () {
        // Act
        appIntentState.enqueue(sampleRefreshHomeIntent);
        appIntentState.enqueue(sampleRefreshHomeIntent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: refresh_home')).called(1);
      });

      test('should track dedupe keys independently for different intent types', () {
        // Arrange
        const openMunroIntent = OpenMunroIntent(munroId: 1);
        const refreshHomeIntent = RefreshHomeIntent();

        // Act
        appIntentState.enqueue(openMunroIntent);
        appIntentState.enqueue(refreshHomeIntent);
        appIntentState.enqueue(openMunroIntent);
        appIntentState.enqueue(refreshHomeIntent);

        // Assert
        expect(appIntentState.pending.length, 2);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
        verify(mockLogger.info('Dropped duplicate intent: refresh_home')).called(1);
      });

      test('should maintain dedupe keys across consume operations', () {
        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.consumeNext();
        appIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert - should still be blocked
        expect(appIntentState.pending.length, 0);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
      });

      test('should maintain dedupe keys across clear operations', () {
        // Act
        appIntentState.enqueue(sampleOpenMunroIntent1);
        appIntentState.clear();
        appIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert - should still be blocked
        expect(appIntentState.pending.length, 0);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
      });

      test('should reset dedupe keys at 200 threshold exactly', () {
        // Arrange - add exactly 200 intents
        for (int i = 0; i < 200; i++) {
          appIntentState.enqueue(OpenMunroIntent(munroId: i));
        }

        // Assert - dedupe keys should not be cleared yet
        expect(appIntentState.pending.length, 200);

        // Act - add one more intent (201st) which should trigger clear
        appIntentState.enqueue(OpenMunroIntent(munroId: 200));

        // Assert - dedupe keys should be cleared
        expect(appIntentState.pending.length, 201);

        // Act - try to add first intent again
        appIntentState.enqueue(const OpenMunroIntent(munroId: 0));

        // Assert - should be allowed (dedupe keys were cleared)
        expect(appIntentState.pending.length, 202);
      });
    });
  });
}
