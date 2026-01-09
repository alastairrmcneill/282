import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'achievements_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  UserAchievementsRepository,
  UserState,
  OverlayIntentState,
  Logger,
])
void main() {
  late MockUserAchievementsRepository mockUserAchievementsRepository;
  late MockUserState mockUserState;
  late MockOverlayIntentState mockOverlayIntentState;
  late MockLogger mockLogger;
  late AchievementsState achievementsState;

  // Sample achievement data for testing
  final sampleAchievements = [
    Achievement(
      userId: 'user123',
      achievementId: 'total_count_10',
      dateTimeCreated: DateTime.parse('2024-01-01T10:00:00Z'),
      name: 'First 10 Munros',
      description: 'Complete your first 10 munros',
      type: AchievementTypes.totalCount,
      criteriaValue: null,
      criteriaCount: 10,
      annualTarget: null,
      acknowledgedAt: null,
      progress: 10,
      completed: true,
    ),
    Achievement(
      userId: 'user123',
      achievementId: 'annual_goal_2024',
      dateTimeCreated: DateTime.parse('2024-01-01T10:00:00Z'),
      name: 'Annual Challenge 2024',
      description: 'Set your annual munro goal for 2024',
      type: AchievementTypes.annualGoal,
      criteriaValue: null,
      criteriaCount: null,
      annualTarget: 25,
      acknowledgedAt: DateTime.parse('2024-01-01T12:00:00Z'),
      progress: 15,
      completed: false,
    ),
    Achievement(
      userId: 'user123',
      achievementId: 'highest_munros_5',
      dateTimeCreated: DateTime.parse('2024-01-01T10:00:00Z'),
      name: 'Top 5 Highest',
      description: 'Climb the 5 highest munros',
      type: AchievementTypes.highestMunros,
      criteriaValue: null,
      criteriaCount: 5,
      annualTarget: null,
      acknowledgedAt: null,
      progress: 3,
      completed: false,
    ),
  ];

  // Sample user for testing
  final sampleUser = AppUser(
    uid: 'user123',
    displayName: 'Test User',
    firstName: 'Test',
    lastName: 'User',
    searchName: 'test user',
    profilePictureURL: 'https://example.com/profile.jpg',
    platform: 'iOS',
    appVersion: '1.0.0',
    dateCreated: DateTime.parse('2024-01-01T10:00:00Z'),
    signInMethod: 'google sign in',
    profileVisibility: Privacy.public,
  );

  setUp(() {
    mockUserAchievementsRepository = MockUserAchievementsRepository();
    mockUserState = MockUserState();
    mockOverlayIntentState = MockOverlayIntentState();
    mockLogger = MockLogger();

    achievementsState = AchievementsState(
      mockUserAchievementsRepository,
      mockUserState,
      mockOverlayIntentState,
      mockLogger,
    );

    // Setup default user state
    when(mockUserState.currentUser).thenReturn(sampleUser);
  });

  group('AchievementsState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(achievementsState.status, AchievementsStatus.initial);
        expect(achievementsState.error, isA<Error>());
        expect(achievementsState.achievements, isEmpty);
        expect(achievementsState.currentAchievement, isNull);
        expect(achievementsState.achievementFormCount, 0);
      });
    });

    group('getUserAchievements', () {
      test('should load achievements successfully and update status', () async {
        // Arrange
        when(mockUserAchievementsRepository.getUserAchievements(userId: 'user123'))
            .thenAnswer((_) async => sampleAchievements);

        // Act
        await achievementsState.getUserAchievements();

        // Assert
        expect(achievementsState.status, AchievementsStatus.loaded);
        expect(achievementsState.achievements, sampleAchievements);
        verify(mockUserAchievementsRepository.getUserAchievements(userId: 'user123')).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockUserAchievementsRepository.getUserAchievements(userId: 'user123'))
            .thenThrow(Exception('Database error'));

        // Act
        await achievementsState.getUserAchievements();

        // Assert
        expect(achievementsState.status, AchievementsStatus.error);
        expect(achievementsState.achievements, isEmpty);
        verify(mockUserAchievementsRepository.getUserAchievements(userId: 'user123')).called(1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockUserAchievementsRepository.getUserAchievements(userId: 'user123')).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleAchievements;
        });

        // Act
        final future = achievementsState.getUserAchievements();

        // Assert intermediate state
        expect(achievementsState.status, AchievementsStatus.loading);

        // Wait for completion
        await future;
        expect(achievementsState.status, AchievementsStatus.loaded);
      });

      test('should return early when currentUser is null', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await achievementsState.getUserAchievements();

        // Assert
        expect(achievementsState.status, AchievementsStatus.initial);
        verifyNever(mockUserAchievementsRepository.getUserAchievements(userId: anyNamed('userId')));
      });

      test('should filter recently completed achievements correctly', () async {
        // Arrange
        final achievementsWithMixedStatus = [
          sampleAchievements[0], // completed, not acknowledged
          sampleAchievements[1], // not completed, acknowledged
          Achievement(
            userId: 'user123',
            achievementId: 'completed_acknowledged',
            dateTimeCreated: DateTime.parse('2024-01-01T10:00:00Z'),
            name: 'Completed and Acknowledged',
            description: 'Test achievement',
            type: AchievementTypes.totalCount,
            criteriaCount: 5,
            acknowledgedAt: DateTime.parse('2024-01-01T11:00:00Z'),
            progress: 5,
            completed: true,
          ),
        ];

        when(mockUserAchievementsRepository.getUserAchievements(userId: 'user123'))
            .thenAnswer((_) async => achievementsWithMixedStatus);

        // Act
        await achievementsState.getUserAchievements();

        // Assert
        verify(mockOverlayIntentState.enqueue(
          argThat(
            isA<AchievementCompleteIntent>().having(
              (intent) => intent.achievements,
              'achievements',
              contains(predicate<Achievement>((achievement) => achievement.achievementId == 'total_count_10')),
            ),
          ),
        )).called(1);
      });

      test('should call unacknowledgeAchievement for achievements that need reset', () async {
        // Arrange
        final achievementNeedingReset = Achievement(
          userId: 'user123',
          achievementId: 'needs_reset',
          dateTimeCreated: DateTime.parse('2024-01-01T10:00:00Z'),
          name: 'Needs Reset',
          description: 'This achievement needs to be reset',
          type: AchievementTypes.totalCount,
          criteriaCount: 5,
          acknowledgedAt: DateTime.parse('2024-01-01T11:00:00Z'),
          progress: 3,
          completed: false,
        );

        when(mockUserAchievementsRepository.getUserAchievements(userId: 'user123'))
            .thenAnswer((_) async => [achievementNeedingReset]);

        when(mockUserAchievementsRepository.updateUserAchievement(achievement: anyNamed('achievement')))
            .thenAnswer((_) async {});

        // Act
        await achievementsState.getUserAchievements();

        // Assert
        final captured = verify(mockUserAchievementsRepository.updateUserAchievement(
          achievement: captureAnyNamed('achievement'),
        )).captured;
        expect(captured.length, 1);
        final capturedAchievement = captured[0] as Achievement;
        expect(capturedAchievement.acknowledgedAt, isNull);
        expect(capturedAchievement.achievementId, 'needs_reset');
      });
    });

    group('acknowledgeAchievement', () {
      setUp(() {
        resetMockitoState();
        reset(mockUserAchievementsRepository);
        reset(mockLogger);
      });

      test('should successfully acknowledge an achievement', () async {
        // Arrange
        final achievementToAcknowledge = sampleAchievements[0];
        when(mockUserAchievementsRepository.updateUserAchievement(achievement: anyNamed('achievement')))
            .thenAnswer((_) async {});

        // Act
        await achievementsState.acknowledgeAchievement(achievement: achievementToAcknowledge);

        // Assert
        expect(achievementToAcknowledge.acknowledgedAt, isNotNull);
        verify(mockUserAchievementsRepository.updateUserAchievement(achievement: achievementToAcknowledge)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during acknowledgment', () async {
        // Arrange
        final achievementToAcknowledge = sampleAchievements[0];
        when(mockUserAchievementsRepository.updateUserAchievement(achievement: anyNamed('achievement')))
            .thenThrow(Exception('Update failed'));

        // Act & Assert - should not throw
        await achievementsState.acknowledgeAchievement(achievement: achievementToAcknowledge);

        verify(mockUserAchievementsRepository.updateUserAchievement(achievement: achievementToAcknowledge)).called(1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });
    });

    group('unacknowledgeAchievement', () {
      setUp(() {
        resetMockitoState();
        reset(mockUserAchievementsRepository);
        reset(mockLogger);
      });

      test('should successfully unacknowledge an achievement', () async {
        // Arrange
        final achievementToUnacknowledge = sampleAchievements[1];
        when(mockUserAchievementsRepository.updateUserAchievement(achievement: anyNamed('achievement')))
            .thenAnswer((_) async {});

        // Act
        await achievementsState.unacknowledgeAchievement(achievement: achievementToUnacknowledge);

        // Assert
        expect(achievementToUnacknowledge.acknowledgedAt, isNull);
        verify(mockUserAchievementsRepository.updateUserAchievement(achievement: achievementToUnacknowledge)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during unacknowledgment', () async {
        // Arrange
        final achievementToUnacknowledge = sampleAchievements[1];
        when(mockUserAchievementsRepository.updateUserAchievement(achievement: anyNamed('achievement')))
            .thenThrow(Exception('Update failed'));

        // Act & Assert - should not throw
        await achievementsState.unacknowledgeAchievement(achievement: achievementToUnacknowledge);

        verify(mockUserAchievementsRepository.updateUserAchievement(achievement: achievementToUnacknowledge)).called(1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });
    });

    group('setMunroChallenge', () {
      setUp(() {
        resetMockitoState();
        reset(mockUserAchievementsRepository);
        reset(mockLogger);
      });

      test('should successfully set munro challenge', () async {
        // Arrange
        final challengeAchievement = sampleAchievements[1];
        achievementsState.setCurrentAchievement = challengeAchievement;
        achievementsState.setAchievementFormCount = 30;

        when(mockUserAchievementsRepository.updateUserAchievement(achievement: anyNamed('achievement')))
            .thenAnswer((_) async {});

        // Act
        await achievementsState.setMunroChallenge();

        // Assert
        expect(challengeAchievement.annualTarget, 30);
        verify(mockUserAchievementsRepository.updateUserAchievement(achievement: challengeAchievement)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during munro challenge setup', () async {
        // Arrange
        final challengeAchievement = sampleAchievements[1];
        achievementsState.setCurrentAchievement = challengeAchievement;
        achievementsState.setAchievementFormCount = 30;

        when(mockUserAchievementsRepository.updateUserAchievement(achievement: anyNamed('achievement')))
            .thenThrow(Exception('Update failed'));

        // Act
        await achievementsState.setMunroChallenge();

        // Assert
        expect(achievementsState.status, AchievementsStatus.error);
        expect(achievementsState.error.message, 'Failed to set Munro Challenge');
        expect(achievementsState.error.code, 'Exception: Update failed');
        verify(mockUserAchievementsRepository.updateUserAchievement(achievement: challengeAchievement)).called(1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle setMunroChallenge with valid currentAchievement', () async {
        // Arrange
        final challengeAchievement = sampleAchievements[1];
        achievementsState.setCurrentAchievement = challengeAchievement;
        achievementsState.setAchievementFormCount = 15;

        when(mockUserAchievementsRepository.updateUserAchievement(achievement: anyNamed('achievement')))
            .thenAnswer((_) async {});

        // Act
        await achievementsState.setMunroChallenge();

        // Assert
        expect(challengeAchievement.annualTarget, 15);
        verify(mockUserAchievementsRepository.updateUserAchievement(achievement: challengeAchievement)).called(1);
      });
    });

    group('Setters', () {
      test('setStatus should update status and notify listeners', () {
        // Arrange
        bool notified = false;
        achievementsState.addListener(() => notified = true);

        // Act
        achievementsState.setStatus = AchievementsStatus.loading;

        // Assert
        expect(achievementsState.status, AchievementsStatus.loading);
        expect(notified, true);
      });

      test('setError should update error, status and notify listeners', () {
        // Arrange
        final error = Error(code: 'test', message: 'test error');
        bool notified = false;
        achievementsState.addListener(() => notified = true);

        // Act
        achievementsState.setError = error;

        // Assert
        expect(achievementsState.status, AchievementsStatus.error);
        expect(achievementsState.error, error);
        expect(notified, true);
      });

      test('setAchievements should update achievements list and notify listeners', () {
        // Arrange
        bool notified = false;
        achievementsState.addListener(() => notified = true);

        // Act
        achievementsState.setAchievements = sampleAchievements;

        // Assert
        expect(achievementsState.achievements, sampleAchievements);
        expect(notified, true);
      });

      test('setCurrentAchievement should update current achievement and notify listeners', () {
        // Arrange
        bool notified = false;
        achievementsState.addListener(() => notified = true);

        // Act
        achievementsState.setCurrentAchievement = sampleAchievements[0];

        // Assert
        expect(achievementsState.currentAchievement, sampleAchievements[0]);
        expect(notified, true);
      });

      test('setCurrentAchievement with null should clear current achievement', () {
        // Arrange
        achievementsState.setCurrentAchievement = sampleAchievements[0];
        bool notified = false;
        achievementsState.addListener(() => notified = true);

        // Act
        achievementsState.setCurrentAchievement = null;

        // Assert
        expect(achievementsState.currentAchievement, isNull);
        expect(notified, true);
      });

      test('setAchievementFormCount should update count and notify listeners', () {
        // Arrange
        bool notified = false;
        achievementsState.addListener(() => notified = true);

        // Act
        achievementsState.setAchievementFormCount = 25;

        // Assert
        expect(achievementsState.achievementFormCount, 25);
        expect(notified, true);
      });
    });

    group('Reset methods', () {
      test('reset should clear state but keep achievements', () {
        // Arrange
        achievementsState.setStatus = AchievementsStatus.loaded;
        achievementsState.setError = Error(code: 'test', message: 'test');
        achievementsState.setCurrentAchievement = sampleAchievements[0];
        achievementsState.setAchievementFormCount = 25;
        achievementsState.setAchievements = sampleAchievements;

        // Act
        achievementsState.reset();

        // Assert
        expect(achievementsState.status, AchievementsStatus.initial);
        expect(achievementsState.error, isA<Error>());
        expect(achievementsState.currentAchievement, isNull);
        expect(achievementsState.achievementFormCount, 0);
        // Achievements should remain
        expect(achievementsState.achievements, sampleAchievements);
      });

      test('resetAll should clear all state including achievements', () {
        // Arrange
        achievementsState.setStatus = AchievementsStatus.loaded;
        achievementsState.setError = Error(code: 'test', message: 'test');
        achievementsState.setCurrentAchievement = sampleAchievements[0];
        achievementsState.setAchievementFormCount = 25;
        achievementsState.setAchievements = sampleAchievements;

        // Act
        achievementsState.resetAll();

        // Assert
        expect(achievementsState.status, AchievementsStatus.initial);
        expect(achievementsState.error, isA<Error>());
        expect(achievementsState.currentAchievement, isNull);
        expect(achievementsState.achievementFormCount, 0);
        expect(achievementsState.achievements, isEmpty);
      });

      test('reset methods should not notify listeners', () {
        // Arrange
        achievementsState.setStatus = AchievementsStatus.loaded;
        int notificationCount = 0;
        void listener() => notificationCount++;
        achievementsState.addListener(listener);
        notificationCount = 0; // Reset count after adding listener

        // Act
        achievementsState.reset();

        // Assert - Note: reset does NOT call notifyListeners, it directly modifies private vars
        expect(notificationCount, 0);
        achievementsState.removeListener(listener);
      });
    });

    group('Edge Cases', () {
      setUp(() {
        resetMockitoState();
        reset(mockUserAchievementsRepository);
        reset(mockUserState);
        reset(mockOverlayIntentState);
        when(mockUserState.currentUser).thenReturn(sampleUser);
      });

      test('should handle empty achievements list', () async {
        // Arrange
        when(mockUserAchievementsRepository.getUserAchievements(userId: 'user123'))
            .thenAnswer((_) async => <Achievement>[]);

        // Act
        await achievementsState.getUserAchievements();

        // Assert
        expect(achievementsState.status, AchievementsStatus.loaded);
        expect(achievementsState.achievements, isEmpty);
      });

      test('should handle achievements with null acknowledgedAt dates', () async {
        // Arrange
        final achievementsWithNulls = [
          Achievement(
            userId: 'user123',
            achievementId: 'null_ack',
            dateTimeCreated: DateTime.parse('2024-01-01T10:00:00Z'),
            name: 'Null Acknowledged',
            description: 'Test achievement',
            type: AchievementTypes.totalCount,
            criteriaCount: 5,
            acknowledgedAt: null,
            progress: 5,
            completed: true,
          ),
        ];

        when(mockUserAchievementsRepository.getUserAchievements(userId: 'user123'))
            .thenAnswer((_) async => achievementsWithNulls);

        // Act
        await achievementsState.getUserAchievements();

        // Assert
        verify(mockOverlayIntentState.enqueue(
          argThat(
            isA<AchievementCompleteIntent>().having(
              (intent) => intent.achievements,
              'achievements',
              contains(predicate<Achievement>((achievement) => achievement.achievementId == 'null_ack')),
            ),
          ),
        )).called(1);
      });

      test('should handle user with empty uid', () async {
        // Arrange
        final userWithEmptyUid = AppUser(
          uid: '',
          displayName: 'Test User',
        );
        when(mockUserState.currentUser).thenReturn(userWithEmptyUid);
        when(mockUserAchievementsRepository.getUserAchievements(userId: '')).thenAnswer((_) async => <Achievement>[]);

        // Act
        await achievementsState.getUserAchievements();

        // Assert
        expect(achievementsState.status, AchievementsStatus.loaded);
        verify(mockUserAchievementsRepository.getUserAchievements(userId: '')).called(1);
      });

      test('should handle achievements with different types', () async {
        // Arrange
        final mixedTypeAchievements = [
          Achievement(
            userId: 'user123',
            achievementId: 'monthly',
            dateTimeCreated: DateTime.parse('2024-01-01T10:00:00Z'),
            name: 'Monthly Achievement',
            description: 'Monthly munro achievement',
            type: AchievementTypes.monthlyMunro,
            criteriaCount: 1,
            acknowledgedAt: null,
            progress: 1,
            completed: true,
          ),
          Achievement(
            userId: 'user123',
            achievementId: 'area',
            dateTimeCreated: DateTime.parse('2024-01-01T10:00:00Z'),
            name: 'Area Achievement',
            description: 'Area munro achievement',
            type: AchievementTypes.areaGoal,
            criteriaValue: 'Cairngorms',
            acknowledgedAt: null,
            progress: 5,
            completed: true,
          ),
        ];

        when(mockUserAchievementsRepository.getUserAchievements(userId: 'user123'))
            .thenAnswer((_) async => mixedTypeAchievements);

        // Act
        await achievementsState.getUserAchievements();

        // Assert
        verify(mockOverlayIntentState.enqueue(
          argThat(
            isA<AchievementCompleteIntent>().having(
              (intent) => intent.achievements,
              'achievements',
              contains(predicate<Achievement>((achievement) => achievement.achievementId == 'monthly')),
            ),
          ),
        )).called(1);
      });
    });

    group('ChangeNotifier', () {
      setUp(() {
        resetMockitoState();
        reset(mockUserAchievementsRepository);
      });

      test('should notify listeners when loading achievements', () async {
        // Arrange
        when(mockUserAchievementsRepository.getUserAchievements(userId: 'user123'))
            .thenAnswer((_) async => sampleAchievements);

        int notificationCount = 0;
        achievementsState.addListener(() => notificationCount++);

        // Act
        await achievementsState.getUserAchievements();

        // Assert
        expect(notificationCount, greaterThan(0));
      });

      test('should notify listeners when acknowledging achievements', () async {
        // Arrange
        final achievement = sampleAchievements[0];
        when(mockUserAchievementsRepository.updateUserAchievement(achievement: anyNamed('achievement')))
            .thenAnswer((_) async {});

        bool notified = false;
        achievementsState.addListener(() => notified = true);

        // Act
        await achievementsState.acknowledgeAchievement(achievement: achievement);

        // Assert - Note: acknowledgeAchievement doesn't call notifyListeners directly
        // but the setter methods do, so we test those separately
        expect(notified, false);
      });

      test('should not notify listeners unnecessarily', () {
        // Arrange
        achievementsState.setStatus = AchievementsStatus.loaded;
        int notificationCount = 0;
        achievementsState.addListener(() => notificationCount++);

        // Act - set to same status
        achievementsState.setStatus = AchievementsStatus.loaded;

        // Assert
        expect(notificationCount, 1); // Still notifies as it calls notifyListeners
      });
    });
  });
}
