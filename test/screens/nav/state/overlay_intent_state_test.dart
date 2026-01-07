import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/nav/state/overlay_intent_state.dart';

import 'overlay_intent_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  Logger,
])
void main() {
  late MockLogger mockLogger;
  late OverlayIntentState overlayIntentState;

  late OverlayIntent sampleHardUpdateIntent;
  late OverlayIntent sampleSoftUpdateIntent;
  late OverlayIntent sampleWhatsNewIntent;
  late OverlayIntent sampleFeedbackSurveyIntent;
  late OverlayIntent sampleAchievementCompleteIntent;
  late OverlayIntent sampleBulkMunroUpdateIntent;
  late OverlayIntent sampleAnnualMunroChallengeIntent;

  setUp(() {
    // Sample overlay intents for testing
    sampleHardUpdateIntent = const HardUpdateDialogIntent();
    sampleSoftUpdateIntent = const SoftUpdateDialogIntent(
      currentVersion: '1.0.0',
      latestVersion: '2.0.0',
      whatsNew: 'New features',
    );
    sampleWhatsNewIntent = const WhatsNewDialogIntent(version: '2.0.0');
    sampleFeedbackSurveyIntent = const FeedbackSurveyIntent(surveyNumber: 1);
    sampleAchievementCompleteIntent = AchievementCompleteIntent(
      achievements: [
        Achievement(
          userId: 'user123',
          achievementId: 'test_achievement_1',
          dateTimeCreated: DateTime.now(),
          name: 'Test Achievement',
          description: 'Test achievement description',
          type: AchievementTypes.totalCount,
          progress: 1,
          completed: true,
        ),
      ],
    );
    sampleBulkMunroUpdateIntent = const BulkMunroUpdateDialogIntent();
    sampleAnnualMunroChallengeIntent = AnnualMunroChallengeDialogIntent(
      achievement: Achievement(
        userId: 'user123',
        achievementId: 'annual_challenge_2024',
        dateTimeCreated: DateTime.now(),
        name: 'Annual Challenge 2024',
        description: 'Complete annual munro challenge',
        type: AchievementTypes.annualGoal,
        annualTarget: 25,
        progress: 25,
        completed: true,
      ),
    );

    mockLogger = MockLogger();
    overlayIntentState = OverlayIntentState(mockLogger);
  });

  group('OverlayIntentState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(overlayIntentState.pending, isEmpty);
        expect(overlayIntentState.next, isNull);
      });

      test('should have immutable pending list', () {
        expect(overlayIntentState.pending, isA<UnmodifiableListView>());
      });
    });

    group('enqueue', () {
      test('should enqueue a single intent', () {
        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        // Assert
        expect(overlayIntentState.pending.length, 1);
        expect(overlayIntentState.next, sampleHardUpdateIntent);
        verifyNever(mockLogger.info(any));
      });

      test('should enqueue multiple different intents', () {
        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);
        overlayIntentState.enqueue(sampleWhatsNewIntent);

        // Assert
        expect(overlayIntentState.pending.length, 3);
        expect(overlayIntentState.next, sampleHardUpdateIntent);
        expect(overlayIntentState.pending[1], sampleSoftUpdateIntent);
        expect(overlayIntentState.pending[2], sampleWhatsNewIntent);
      });

      test('should prevent duplicate intent based on dedupeKey', () {
        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        // Assert
        expect(overlayIntentState.pending.length, 1);
        verify(mockLogger.info('Dropped duplicate intent: hard_update_dialog')).called(1);
      });

      test('should allow different intents with unique dedupeKeys', () {
        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);
        overlayIntentState.enqueue(sampleFeedbackSurveyIntent);

        // Assert
        expect(overlayIntentState.pending.length, 3);
        verifyNever(mockLogger.info(any));
      });

      test('should prevent duplicate soft update intents', () {
        // Arrange
        final softUpdate1 = const SoftUpdateDialogIntent(
          currentVersion: '1.0.0',
          latestVersion: '2.0.0',
          whatsNew: 'New features',
        );
        final softUpdate2 = const SoftUpdateDialogIntent(
          currentVersion: '1.5.0',
          latestVersion: '3.0.0',
          whatsNew: 'More features',
        );

        // Act
        overlayIntentState.enqueue(softUpdate1);
        overlayIntentState.enqueue(softUpdate2);

        // Assert
        expect(overlayIntentState.pending.length, 1);
        verify(mockLogger.info('Dropped duplicate intent: soft_update_dialog')).called(1);
      });

      test('should prevent duplicate achievement intents with same achievements', () {
        // Arrange
        final achievement = Achievement(
          userId: 'user123',
          achievementId: 'test_achievement_1',
          dateTimeCreated: DateTime.now(),
          name: 'Test Achievement',
          description: 'Test achievement description',
          type: AchievementTypes.totalCount,
          progress: 1,
          completed: true,
        );
        final intent1 = AchievementCompleteIntent(achievements: [achievement]);
        final intent2 = AchievementCompleteIntent(achievements: [achievement]);

        // Act
        overlayIntentState.enqueue(intent1);
        overlayIntentState.enqueue(intent2);

        // Assert
        expect(overlayIntentState.pending.length, 1);
        verify(mockLogger.info(argThat(startsWith('Dropped duplicate intent: achievement_complete')))).called(1);
      });

      test('should allow achievement intents with different achievements', () {
        // Arrange
        final achievement1 = Achievement(
          userId: 'user123',
          achievementId: 'test_achievement_1',
          dateTimeCreated: DateTime.now(),
          name: 'Test Achievement 1',
          description: 'Test achievement 1 description',
          type: AchievementTypes.totalCount,
          progress: 1,
          completed: true,
        );
        final achievement2 = Achievement(
          userId: 'user123',
          achievementId: 'test_achievement_2',
          dateTimeCreated: DateTime.now(),
          name: 'Test Achievement 2',
          description: 'Test achievement 2 description',
          type: AchievementTypes.annualGoal,
          progress: 1,
          completed: true,
        );
        final intent1 = AchievementCompleteIntent(achievements: [achievement1]);
        final intent2 = AchievementCompleteIntent(achievements: [achievement2]);

        // Act
        overlayIntentState.enqueue(intent1);
        overlayIntentState.enqueue(intent2);

        // Assert
        expect(overlayIntentState.pending.length, 2);
        verifyNever(mockLogger.info(any));
      });

      test('should clear dedupe keys after 200 unique intents', () {
        // Act - Enqueue 201 different intents (using feedback survey with different numbers)
        for (int i = 0; i < 201; i++) {
          // We need unique dedupe keys, but feedback survey always has same dedupe key
          // So we'll use achievement intents with different IDs
          final achievement = Achievement(
            userId: 'user123',
            achievementId: 'test_achievement_$i',
            dateTimeCreated: DateTime.now(),
            name: 'Test Achievement $i',
            description: 'Test achievement $i description',
            type: AchievementTypes.totalCount,
            progress: 1,
            completed: true,
          );
          overlayIntentState.enqueue(AchievementCompleteIntent(achievements: [achievement]));
        }

        // Assert
        expect(overlayIntentState.pending.length, 201);

        // Now try to enqueue the first intent again - it should be allowed since dedupe keys were cleared
        final firstAchievement = Achievement(
          userId: 'user123',
          achievementId: 'test_achievement_0',
          dateTimeCreated: DateTime.now(),
          name: 'Test Achievement 0',
          description: 'Test achievement 0 description',
          type: AchievementTypes.totalCount,
          progress: 1,
          completed: true,
        );
        overlayIntentState.enqueue(AchievementCompleteIntent(achievements: [firstAchievement]));

        // Should be added since dedupe keys were cleared
        expect(overlayIntentState.pending.length, 202);
      });

      test('should maintain order of enqueued intents', () {
        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);
        overlayIntentState.enqueue(sampleWhatsNewIntent);
        overlayIntentState.enqueue(sampleFeedbackSurveyIntent);

        // Assert
        expect(overlayIntentState.pending[0], sampleHardUpdateIntent);
        expect(overlayIntentState.pending[1], sampleSoftUpdateIntent);
        expect(overlayIntentState.pending[2], sampleWhatsNewIntent);
        expect(overlayIntentState.pending[3], sampleFeedbackSurveyIntent);
      });

      test('should enqueue all different overlay intent types', () {
        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);
        overlayIntentState.enqueue(sampleWhatsNewIntent);
        overlayIntentState.enqueue(sampleFeedbackSurveyIntent);
        overlayIntentState.enqueue(sampleAchievementCompleteIntent);
        overlayIntentState.enqueue(sampleBulkMunroUpdateIntent);
        overlayIntentState.enqueue(sampleAnnualMunroChallengeIntent);

        // Assert
        expect(overlayIntentState.pending.length, 7);
        expect(overlayIntentState.pending, contains(sampleHardUpdateIntent));
        expect(overlayIntentState.pending, contains(sampleSoftUpdateIntent));
        expect(overlayIntentState.pending, contains(sampleWhatsNewIntent));
        expect(overlayIntentState.pending, contains(sampleFeedbackSurveyIntent));
        expect(overlayIntentState.pending, contains(sampleAchievementCompleteIntent));
        expect(overlayIntentState.pending, contains(sampleBulkMunroUpdateIntent));
        expect(overlayIntentState.pending, contains(sampleAnnualMunroChallengeIntent));
      });
    });

    group('consumeNext', () {
      test('should return null when queue is empty', () {
        // Act
        final result = overlayIntentState.consumeNext();

        // Assert
        expect(result, isNull);
      });

      test('should consume and return the first intent', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);

        // Act
        final result = overlayIntentState.consumeNext();

        // Assert
        expect(result, sampleHardUpdateIntent);
        expect(overlayIntentState.pending.length, 1);
        expect(overlayIntentState.next, sampleSoftUpdateIntent);
      });

      test('should consume all intents in FIFO order', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);
        overlayIntentState.enqueue(sampleWhatsNewIntent);

        // Act & Assert
        expect(overlayIntentState.consumeNext(), sampleHardUpdateIntent);
        expect(overlayIntentState.pending.length, 2);

        expect(overlayIntentState.consumeNext(), sampleSoftUpdateIntent);
        expect(overlayIntentState.pending.length, 1);

        expect(overlayIntentState.consumeNext(), sampleWhatsNewIntent);
        expect(overlayIntentState.pending.length, 0);

        expect(overlayIntentState.consumeNext(), isNull);
      });

      test('should update next getter after consuming', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);

        expect(overlayIntentState.next, sampleHardUpdateIntent);

        // Act
        overlayIntentState.consumeNext();

        // Assert
        expect(overlayIntentState.next, sampleSoftUpdateIntent);

        // Act
        overlayIntentState.consumeNext();

        // Assert
        expect(overlayIntentState.next, isNull);
      });

      test('should handle consuming from a single-item queue', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        // Act
        final result = overlayIntentState.consumeNext();

        // Assert
        expect(result, sampleHardUpdateIntent);
        expect(overlayIntentState.pending, isEmpty);
        expect(overlayIntentState.next, isNull);
      });
    });

    group('clear', () {
      test('should clear empty queue', () {
        // Act
        overlayIntentState.clear();

        // Assert
        expect(overlayIntentState.pending, isEmpty);
        expect(overlayIntentState.next, isNull);
      });

      test('should clear all intents from queue', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);
        overlayIntentState.enqueue(sampleWhatsNewIntent);

        expect(overlayIntentState.pending.length, 3);

        // Act
        overlayIntentState.clear();

        // Assert
        expect(overlayIntentState.pending, isEmpty);
        expect(overlayIntentState.next, isNull);
      });

      test('should not clear dedupe keys', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.clear();

        // Act - Try to enqueue the same intent again
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        // Assert - Should still be blocked by dedupe
        expect(overlayIntentState.pending, isEmpty);
        verify(mockLogger.info('Dropped duplicate intent: hard_update_dialog')).called(1);
      });
    });

    group('next getter', () {
      test('should return null for empty queue', () {
        expect(overlayIntentState.next, isNull);
      });

      test('should return first intent without removing it', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);

        // Act & Assert
        expect(overlayIntentState.next, sampleHardUpdateIntent);
        expect(overlayIntentState.pending.length, 2);

        // Calling next again should return same intent
        expect(overlayIntentState.next, sampleHardUpdateIntent);
        expect(overlayIntentState.pending.length, 2);
      });

      test('should update after consuming', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);
        overlayIntentState.enqueue(sampleWhatsNewIntent);

        // Act & Assert
        expect(overlayIntentState.next, sampleHardUpdateIntent);

        overlayIntentState.consumeNext();
        expect(overlayIntentState.next, sampleSoftUpdateIntent);

        overlayIntentState.consumeNext();
        expect(overlayIntentState.next, sampleWhatsNewIntent);

        overlayIntentState.consumeNext();
        expect(overlayIntentState.next, isNull);
      });
    });

    group('pending getter', () {
      test('should return empty list for empty queue', () {
        expect(overlayIntentState.pending, isEmpty);
        expect(overlayIntentState.pending, isA<UnmodifiableListView>());
      });

      test('should return all pending intents in order', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);
        overlayIntentState.enqueue(sampleWhatsNewIntent);

        // Assert
        final pending = overlayIntentState.pending;
        expect(pending.length, 3);
        expect(pending[0], sampleHardUpdateIntent);
        expect(pending[1], sampleSoftUpdateIntent);
        expect(pending[2], sampleWhatsNewIntent);
      });

      test('should return immutable list view', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        // Act
        final pending = overlayIntentState.pending;

        // Assert
        expect(pending, isA<UnmodifiableListView<OverlayIntent>>());
        expect(() => (pending as List).add(sampleSoftUpdateIntent), throwsUnsupportedError);
      });
    });

    group('Edge Cases', () {
      test('should handle rapid enqueue and consume operations', () {
        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        expect(overlayIntentState.consumeNext(), sampleHardUpdateIntent);

        overlayIntentState.enqueue(sampleSoftUpdateIntent);
        expect(overlayIntentState.consumeNext(), sampleSoftUpdateIntent);

        overlayIntentState.enqueue(sampleWhatsNewIntent);
        expect(overlayIntentState.consumeNext(), sampleWhatsNewIntent);

        // Assert
        expect(overlayIntentState.pending, isEmpty);
      });

      test('should handle clearing multiple times', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.clear();

        // Act
        overlayIntentState.clear();
        overlayIntentState.clear();

        // Assert
        expect(overlayIntentState.pending, isEmpty);
      });

      test('should handle consuming from empty queue multiple times', () {
        // Act & Assert
        expect(overlayIntentState.consumeNext(), isNull);
        expect(overlayIntentState.consumeNext(), isNull);
        expect(overlayIntentState.consumeNext(), isNull);
      });

      test('should handle enqueuing after clearing', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.clear();

        // Act
        overlayIntentState.enqueue(sampleSoftUpdateIntent);

        // Assert
        expect(overlayIntentState.pending.length, 1);
        expect(overlayIntentState.next, sampleSoftUpdateIntent);
      });

      test('should handle enqueuing after consuming all', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.consumeNext();

        expect(overlayIntentState.pending, isEmpty);

        // Act
        overlayIntentState.enqueue(sampleSoftUpdateIntent);

        // Assert
        expect(overlayIntentState.pending.length, 1);
        expect(overlayIntentState.next, sampleSoftUpdateIntent);
      });

      test('should maintain FIFO order with mixed operations', () {
        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);

        expect(overlayIntentState.consumeNext(), sampleHardUpdateIntent);

        overlayIntentState.enqueue(sampleWhatsNewIntent);
        overlayIntentState.enqueue(sampleFeedbackSurveyIntent);

        expect(overlayIntentState.consumeNext(), sampleSoftUpdateIntent);
        expect(overlayIntentState.consumeNext(), sampleWhatsNewIntent);
        expect(overlayIntentState.consumeNext(), sampleFeedbackSurveyIntent);

        // Assert
        expect(overlayIntentState.pending, isEmpty);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when enqueuing intent', () {
        // Arrange
        bool notified = false;
        overlayIntentState.addListener(() => notified = true);

        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when consuming intent', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        bool notified = false;
        overlayIntentState.addListener(() => notified = true);

        // Act
        overlayIntentState.consumeNext();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when clearing queue', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        bool notified = false;
        overlayIntentState.addListener(() => notified = true);

        // Act
        overlayIntentState.clear();

        // Assert
        expect(notified, true);
      });

      test('should not notify listeners when enqueuing duplicate', () {
        // Arrange
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        bool notified = false;
        overlayIntentState.addListener(() => notified = true);

        // Act - Try to enqueue duplicate
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        // Assert
        expect(notified, false);
        verify(mockLogger.info('Dropped duplicate intent: hard_update_dialog')).called(1);
      });

      test('should not notify listeners when consuming from empty queue', () {
        // Arrange
        bool notified = false;
        overlayIntentState.addListener(() => notified = true);

        // Act
        overlayIntentState.consumeNext();

        // Assert
        expect(notified, false);
      });

      test('should notify listeners multiple times for multiple operations', () {
        // Arrange
        int notificationCount = 0;
        overlayIntentState.addListener(() => notificationCount++);

        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent); // 1
        overlayIntentState.enqueue(sampleSoftUpdateIntent); // 2
        overlayIntentState.consumeNext(); // 3
        overlayIntentState.enqueue(sampleWhatsNewIntent); // 4
        overlayIntentState.clear(); // 5

        // Assert
        expect(notificationCount, 5);
      });
    });

    group('Dedupe Key Logic', () {
      test('should use correct dedupe key for HardUpdateDialogIntent', () {
        // Act
        overlayIntentState.enqueue(sampleHardUpdateIntent);
        overlayIntentState.enqueue(sampleHardUpdateIntent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: hard_update_dialog')).called(1);
      });

      test('should use correct dedupe key for SoftUpdateDialogIntent', () {
        // Act
        overlayIntentState.enqueue(sampleSoftUpdateIntent);
        overlayIntentState.enqueue(sampleSoftUpdateIntent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: soft_update_dialog')).called(1);
      });

      test('should use correct dedupe key for WhatsNewDialogIntent', () {
        // Act
        overlayIntentState.enqueue(sampleWhatsNewIntent);
        overlayIntentState.enqueue(sampleWhatsNewIntent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: whats_new_dialog')).called(1);
      });

      test('should use correct dedupe key for FeedbackSurveyIntent', () {
        // Act
        overlayIntentState.enqueue(sampleFeedbackSurveyIntent);
        overlayIntentState.enqueue(sampleFeedbackSurveyIntent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: feedback_survey')).called(1);
      });

      test('should use correct dedupe key for BulkMunroUpdateDialogIntent', () {
        // Act
        overlayIntentState.enqueue(sampleBulkMunroUpdateIntent);
        overlayIntentState.enqueue(sampleBulkMunroUpdateIntent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: bulk_munro_update_dialog')).called(1);
      });

      test('should use correct dedupe key for AnnualMunroChallengeDialogIntent', () {
        // Act
        overlayIntentState.enqueue(sampleAnnualMunroChallengeIntent);
        overlayIntentState.enqueue(sampleAnnualMunroChallengeIntent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: annual_munro_challenge_dialog')).called(1);
      });

      test('should use achievement-specific dedupe key for AchievementCompleteIntent', () {
        // Arrange
        final achievement = Achievement(
          userId: 'user123',
          achievementId: 'test_achievement_1',
          dateTimeCreated: DateTime.now(),
          name: 'Test Achievement',
          description: 'Test achievement description',
          type: AchievementTypes.totalCount,
          progress: 1,
          completed: true,
        );
        final intent = AchievementCompleteIntent(achievements: [achievement]);

        // Act
        overlayIntentState.enqueue(intent);
        overlayIntentState.enqueue(intent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: achievement_complete:test_achievement_1')).called(1);
      });

      test('should use comma-separated achievement IDs in dedupe key', () {
        // Arrange
        final achievement1 = Achievement(
          userId: 'user123',
          achievementId: 'achievement_1',
          dateTimeCreated: DateTime.now(),
          name: 'Achievement 1',
          description: 'Achievement 1 description',
          type: AchievementTypes.totalCount,
          progress: 1,
          completed: true,
        );
        final achievement2 = Achievement(
          userId: 'user123',
          achievementId: 'achievement_2',
          dateTimeCreated: DateTime.now(),
          name: 'Achievement 2',
          description: 'Achievement 2 description',
          type: AchievementTypes.annualGoal,
          progress: 1,
          completed: true,
        );
        final intent = AchievementCompleteIntent(achievements: [achievement1, achievement2]);

        // Act
        overlayIntentState.enqueue(intent);
        overlayIntentState.enqueue(intent);

        // Assert
        verify(mockLogger.info('Dropped duplicate intent: achievement_complete:achievement_1,achievement_2')).called(1);
      });
    });
  });
}
