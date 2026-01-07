import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'navigation_intent_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  Logger,
])
void main() {
  late MockLogger mockLogger;
  late NavigationIntentState navigationIntentState;

  late OpenMunroIntent sampleOpenMunroIntent1;
  late OpenMunroIntent sampleOpenMunroIntent2;
  late RefreshHomeIntent sampleRefreshHomeIntent;

  setUp(() {
    // Sample intent data for testing
    sampleOpenMunroIntent1 = const OpenMunroIntent(munroId: 1);
    sampleOpenMunroIntent2 = const OpenMunroIntent(munroId: 2);
    sampleRefreshHomeIntent = const RefreshHomeIntent();

    mockLogger = MockLogger();
    navigationIntentState = NavigationIntentState(mockLogger);
  });

  group('NavigationIntentState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(navigationIntentState.pending, isEmpty);
        expect(navigationIntentState.next, isNull);
      });
    });

    group('enqueue', () {
      test('should add intent to queue', () {
        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert
        expect(navigationIntentState.pending.length, 1);
        expect(navigationIntentState.pending.first, sampleOpenMunroIntent1);
        expect(navigationIntentState.next, sampleOpenMunroIntent1);
      });

      test('should add multiple intents to queue in order', () {
        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleOpenMunroIntent2);
        navigationIntentState.enqueue(sampleRefreshHomeIntent);

        // Assert
        expect(navigationIntentState.pending.length, 3);
        expect(navigationIntentState.pending[0], sampleOpenMunroIntent1);
        expect(navigationIntentState.pending[1], sampleOpenMunroIntent2);
        expect(navigationIntentState.pending[2], sampleRefreshHomeIntent);
        expect(navigationIntentState.next, sampleOpenMunroIntent1);
      });

      test('should not add duplicate intent based on dedupeKey', () {
        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert
        expect(navigationIntentState.pending.length, 1);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
      });

      test('should allow different intents with different dedupeKeys', () {
        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleOpenMunroIntent2);

        // Assert
        expect(navigationIntentState.pending.length, 2);
        verifyNever(mockLogger.info(any));
      });

      test('should clear dedupe keys after 200 entries', () {
        // Arrange - add 201 different intents
        for (int i = 0; i < 201; i++) {
          navigationIntentState.enqueue(OpenMunroIntent(munroId: i));
        }

        // Assert - all intents should be added (no duplicates dropped)
        expect(navigationIntentState.pending.length, 201);
        verifyNever(mockLogger.info(argThat(contains('Dropped duplicate intent'))));

        // Act - try to add the first intent again (dedupe keys should be cleared)
        navigationIntentState.enqueue(const OpenMunroIntent(munroId: 0));

        // Assert - the duplicate should be added because dedupe keys were cleared
        expect(navigationIntentState.pending.length, 202);
        verifyNever(mockLogger.info(argThat(contains('Dropped duplicate intent'))));
      });

      test('should handle RefreshHomeIntent deduplication', () {
        // Act
        navigationIntentState.enqueue(sampleRefreshHomeIntent);
        navigationIntentState.enqueue(sampleRefreshHomeIntent);

        // Assert
        expect(navigationIntentState.pending.length, 1);
        verify(mockLogger.info('Dropped duplicate intent: refresh_home')).called(1);
      });

      test('should allow adding different types of intents', () {
        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleRefreshHomeIntent);
        navigationIntentState.enqueue(sampleOpenMunroIntent2);

        // Assert
        expect(navigationIntentState.pending.length, 3);
        expect(navigationIntentState.pending[0], isA<OpenMunroIntent>());
        expect(navigationIntentState.pending[1], isA<RefreshHomeIntent>());
        expect(navigationIntentState.pending[2], isA<OpenMunroIntent>());
      });
    });

    group('consumeNext', () {
      test('should return and remove first intent from queue', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleOpenMunroIntent2);

        // Act
        final consumed = navigationIntentState.consumeNext();

        // Assert
        expect(consumed, sampleOpenMunroIntent1);
        expect(navigationIntentState.pending.length, 1);
        expect(navigationIntentState.pending.first, sampleOpenMunroIntent2);
        expect(navigationIntentState.next, sampleOpenMunroIntent2);
      });

      test('should return null when queue is empty', () {
        // Act
        final consumed = navigationIntentState.consumeNext();

        // Assert
        expect(consumed, isNull);
        expect(navigationIntentState.pending, isEmpty);
        expect(navigationIntentState.next, isNull);
      });

      test('should consume all intents in order', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleRefreshHomeIntent);
        navigationIntentState.enqueue(sampleOpenMunroIntent2);

        // Act & Assert
        final first = navigationIntentState.consumeNext();
        expect(first, sampleOpenMunroIntent1);
        expect(navigationIntentState.pending.length, 2);

        final second = navigationIntentState.consumeNext();
        expect(second, sampleRefreshHomeIntent);
        expect(navigationIntentState.pending.length, 1);

        final third = navigationIntentState.consumeNext();
        expect(third, sampleOpenMunroIntent2);
        expect(navigationIntentState.pending.length, 0);

        final fourth = navigationIntentState.consumeNext();
        expect(fourth, isNull);
      });

      test('should update next property correctly after consumption', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleOpenMunroIntent2);

        // Act & Assert
        expect(navigationIntentState.next, sampleOpenMunroIntent1);

        navigationIntentState.consumeNext();
        expect(navigationIntentState.next, sampleOpenMunroIntent2);

        navigationIntentState.consumeNext();
        expect(navigationIntentState.next, isNull);
      });

      test('should allow re-enqueueing consumed intent', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.consumeNext();

        // The dedupe key should still be in the set, so re-enqueueing should be blocked
        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert - should be dropped as duplicate
        expect(navigationIntentState.pending.length, 0);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
      });
    });

    group('clear', () {
      test('should clear all intents from queue', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleOpenMunroIntent2);
        navigationIntentState.enqueue(sampleRefreshHomeIntent);

        // Act
        navigationIntentState.clear();

        // Assert
        expect(navigationIntentState.pending, isEmpty);
        expect(navigationIntentState.next, isNull);
      });

      test('should work when queue is already empty', () {
        // Act
        navigationIntentState.clear();

        // Assert
        expect(navigationIntentState.pending, isEmpty);
        expect(navigationIntentState.next, isNull);
      });

      test('should not clear dedupe keys', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.clear();

        // Act - try to enqueue same intent after clear
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert - should still be dropped as duplicate
        expect(navigationIntentState.pending.length, 0);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
      });
    });

    group('next property', () {
      test('should return first intent without removing it', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleOpenMunroIntent2);

        // Act
        final nextIntent1 = navigationIntentState.next;
        final nextIntent2 = navigationIntentState.next;

        // Assert
        expect(nextIntent1, sampleOpenMunroIntent1);
        expect(nextIntent2, sampleOpenMunroIntent1);
        expect(navigationIntentState.pending.length, 2);
      });

      test('should return null when queue is empty', () {
        // Act
        final nextIntent = navigationIntentState.next;

        // Assert
        expect(nextIntent, isNull);
      });
    });

    group('pending property', () {
      test('should return unmodifiable view of queue', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleOpenMunroIntent2);

        // Act
        final pendingList = navigationIntentState.pending;

        // Assert
        expect(pendingList, isA<UnmodifiableListView>());
        expect(pendingList.length, 2);
      });

      test('should reflect current state of queue', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        expect(navigationIntentState.pending.length, 1);

        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent2);

        // Assert
        expect(navigationIntentState.pending.length, 2);
      });
    });

    group('Edge Cases', () {
      test('should handle enqueuing and consuming single intent', () {
        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        final consumed = navigationIntentState.consumeNext();

        // Assert
        expect(consumed, sampleOpenMunroIntent1);
        expect(navigationIntentState.pending, isEmpty);
        expect(navigationIntentState.next, isNull);
      });

      test('should handle multiple consume operations on empty queue', () {
        // Act
        final consumed1 = navigationIntentState.consumeNext();
        final consumed2 = navigationIntentState.consumeNext();
        final consumed3 = navigationIntentState.consumeNext();

        // Assert
        expect(consumed1, isNull);
        expect(consumed2, isNull);
        expect(consumed3, isNull);
      });

      test('should handle multiple clear operations', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        // Act
        navigationIntentState.clear();
        navigationIntentState.clear();
        navigationIntentState.clear();

        // Assert
        expect(navigationIntentState.pending, isEmpty);
      });

      test('should handle alternating enqueue and consume', () {
        // Act & Assert
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        expect(navigationIntentState.pending.length, 1);

        final consumed1 = navigationIntentState.consumeNext();
        expect(consumed1, sampleOpenMunroIntent1);
        expect(navigationIntentState.pending.length, 0);

        navigationIntentState.enqueue(sampleOpenMunroIntent2);
        expect(navigationIntentState.pending.length, 1);

        final consumed2 = navigationIntentState.consumeNext();
        expect(consumed2, sampleOpenMunroIntent2);
        expect(navigationIntentState.pending.length, 0);
      });

      test('should handle same munroId intents as duplicates', () {
        // Arrange
        const intent1 = OpenMunroIntent(munroId: 42);
        const intent2 = OpenMunroIntent(munroId: 42);

        // Act
        navigationIntentState.enqueue(intent1);
        navigationIntentState.enqueue(intent2);

        // Assert
        expect(navigationIntentState.pending.length, 1);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:42')).called(1);
      });

      test('should handle different munroId intents as unique', () {
        // Arrange
        const intent1 = OpenMunroIntent(munroId: 1);
        const intent2 = OpenMunroIntent(munroId: 2);
        const intent3 = OpenMunroIntent(munroId: 3);

        // Act
        navigationIntentState.enqueue(intent1);
        navigationIntentState.enqueue(intent2);
        navigationIntentState.enqueue(intent3);

        // Assert
        expect(navigationIntentState.pending.length, 3);
        verifyNever(mockLogger.info(any));
      });

      test('should handle large number of unique intents', () {
        // Arrange & Act
        for (int i = 0; i < 100; i++) {
          navigationIntentState.enqueue(OpenMunroIntent(munroId: i));
        }

        // Assert
        expect(navigationIntentState.pending.length, 100);
        verifyNever(mockLogger.info(argThat(contains('Dropped duplicate intent'))));
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when enqueuing intent', () {
        bool notified = false;
        navigationIntentState.addListener(() => notified = true);

        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when consuming intent', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        bool notified = false;
        navigationIntentState.addListener(() => notified = true);

        // Act
        navigationIntentState.consumeNext();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when clearing queue', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        bool notified = false;
        navigationIntentState.addListener(() => notified = true);

        // Act
        navigationIntentState.clear();

        // Assert
        expect(notified, true);
      });

      test('should not notify listeners when enqueuing duplicate', () {
        // Arrange
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        bool notified = false;
        navigationIntentState.addListener(() => notified = true);

        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert
        expect(notified, false);
      });

      test('should notify listeners when consuming from empty queue', () {
        bool notified = false;
        navigationIntentState.addListener(() => notified = true);

        // Act
        navigationIntentState.consumeNext();

        // Assert - consumeNext on empty queue should not notify
        expect(notified, false);
      });

      test('should notify listeners multiple times for multiple operations', () {
        int notificationCount = 0;
        navigationIntentState.addListener(() => notificationCount++);

        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.enqueue(sampleOpenMunroIntent2);
        navigationIntentState.consumeNext();
        navigationIntentState.clear();

        // Assert
        expect(notificationCount, 4);
      });

      test('should notify listeners when clearing empty queue', () {
        bool notified = false;
        navigationIntentState.addListener(() => notified = true);

        // Act
        navigationIntentState.clear();

        // Assert
        expect(notified, true);
      });
    });

    group('Dedupe Key Management', () {
      test('should use correct dedupe key for OpenMunroIntent', () {
        // Arrange
        const intent = OpenMunroIntent(munroId: 123);

        // Act
        navigationIntentState.enqueue(intent);
        navigationIntentState.enqueue(intent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: open_munro:123')).called(1);
      });

      test('should use correct dedupe key for RefreshHomeIntent', () {
        // Act
        navigationIntentState.enqueue(sampleRefreshHomeIntent);
        navigationIntentState.enqueue(sampleRefreshHomeIntent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: refresh_home')).called(1);
      });

      test('should track dedupe keys independently for different intent types', () {
        // Arrange
        const openMunroIntent = OpenMunroIntent(munroId: 1);
        const refreshHomeIntent = RefreshHomeIntent();

        // Act
        navigationIntentState.enqueue(openMunroIntent);
        navigationIntentState.enqueue(refreshHomeIntent);
        navigationIntentState.enqueue(openMunroIntent);
        navigationIntentState.enqueue(refreshHomeIntent);

        // Assert
        expect(navigationIntentState.pending.length, 2);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
        verify(mockLogger.info('Dropped duplicate intent: refresh_home')).called(1);
      });

      test('should maintain dedupe keys across consume operations', () {
        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.consumeNext();
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert - should still be blocked
        expect(navigationIntentState.pending.length, 0);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
      });

      test('should maintain dedupe keys across clear operations', () {
        // Act
        navigationIntentState.enqueue(sampleOpenMunroIntent1);
        navigationIntentState.clear();
        navigationIntentState.enqueue(sampleOpenMunroIntent1);

        // Assert - should still be blocked
        expect(navigationIntentState.pending.length, 0);
        verify(mockLogger.info('Dropped duplicate intent: open_munro:1')).called(1);
      });

      test('should reset dedupe keys at 200 threshold exactly', () {
        // Arrange - add exactly 200 intents
        for (int i = 0; i < 200; i++) {
          navigationIntentState.enqueue(OpenMunroIntent(munroId: i));
        }

        // Assert - dedupe keys should not be cleared yet
        expect(navigationIntentState.pending.length, 200);

        // Act - add one more intent (201st) which should trigger clear
        navigationIntentState.enqueue(OpenMunroIntent(munroId: 200));

        // Assert - dedupe keys should be cleared
        expect(navigationIntentState.pending.length, 201);

        // Act - try to add first intent again
        navigationIntentState.enqueue(const OpenMunroIntent(munroId: 0));

        // Assert - should be allowed (dedupe keys were cleared)
        expect(navigationIntentState.pending.length, 202);
      });
    });
  });
}
