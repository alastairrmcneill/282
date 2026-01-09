import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'in_app_onboarding_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  UserState,
  MunroCompletionState,
  BulkMunroUpdateState,
  AchievementsState,
  UserAchievementsRepository,
  MunroState,
  AppFlagsRepository,
  Analytics,
])
void main() {
  late MockUserState mockUserState;
  late MockMunroCompletionState mockMunroCompletionState;
  late MockBulkMunroUpdateState mockBulkMunroUpdateState;
  late MockAchievementsState mockAchievementsState;
  late MockUserAchievementsRepository mockUserAchievementsRepository;
  late MockMunroState mockMunroState;
  late MockAppFlagsRepository mockAppFlagsRepository;
  late MockAnalytics mockAnalytics;
  late InAppOnboardingState inAppOnboardingState;

  late AppUser sampleUser;
  late List<MunroCompletion> sampleMunroCompletions;
  late Achievement sampleAchievement;

  setUp(() {
    // Sample data for testing
    sampleUser = AppUser(
      uid: 'user123',
      displayName: 'Test User',
      profilePictureURL: 'https://example.com/profile.jpg',
      searchName: 'test user',
    );

    sampleMunroCompletions = [
      MunroCompletion(
        munroId: 1,
        userId: 'user123',
        dateTimeCompleted: DateTime(2024, 1, 1),
      ),
      MunroCompletion(
        munroId: 2,
        userId: 'user123',
        dateTimeCompleted: DateTime(2024, 2, 1),
      ),
    ];

    sampleAchievement = Achievement(
      userId: 'user123',
      achievementId: 'achievement1',
      dateTimeCreated: DateTime(2024, 1, 1),
      name: 'First Munro',
      description: 'Complete your first Munro',
      type: 'munro_challenge',
      progress: 1,
      completed: true,
    );

    mockUserState = MockUserState();
    mockMunroCompletionState = MockMunroCompletionState();
    mockBulkMunroUpdateState = MockBulkMunroUpdateState();
    mockAchievementsState = MockAchievementsState();
    mockUserAchievementsRepository = MockUserAchievementsRepository();
    mockMunroState = MockMunroState();
    mockAppFlagsRepository = MockAppFlagsRepository();
    mockAnalytics = MockAnalytics();

    inAppOnboardingState = InAppOnboardingState(
      mockUserState,
      mockMunroCompletionState,
      mockBulkMunroUpdateState,
      mockAchievementsState,
      mockUserAchievementsRepository,
      mockMunroState,
      mockAppFlagsRepository,
      mockAnalytics,
    );

    // Default mock behavior
    when(mockUserState.currentUser).thenReturn(sampleUser);
    when(mockMunroCompletionState.munroCompletions).thenReturn(sampleMunroCompletions);
  });

  group('InAppOnboardingState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(inAppOnboardingState.status, InAppOnboardingStatus.initial);
        expect(inAppOnboardingState.error, isA<Error>());
        expect(inAppOnboardingState.currentPage, 0);
      });
    });

    group('init', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockUserState.readUser(uid: 'user123')).called(1);
        verify(mockMunroCompletionState.loadUserMunroCompletions()).called(1);
        verify(mockBulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions).called(1);
        verify(mockAchievementsState.reset()).called(1);
        verify(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(userId: 'user123')).called(1);
        verify(mockAchievementsState.setCurrentAchievement = sampleAchievement).called(1);
        verify(mockMunroState.setFilterString = '').called(1);
      });

      test('should track analytics events on init', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {
            AnalyticsProp.screenIndex: 0,
          },
        )).called(1);
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingProgress,
          props: {
            AnalyticsProp.status: 'started',
          },
        )).called(1);
      });

      test('should handle error when reading user fails', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenThrow(Exception('User not found'));
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act & Assert
        expect(
          () async => await inAppOnboardingState.init('user123'),
          throwsException,
        );
      });

      test('should handle error when loading munro completions fails', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => sampleUser);
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenThrow(Exception('Database error'));
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act & Assert
        expect(
          () async => await inAppOnboardingState.init('user123'),
          throwsException,
        );
      });

      test('should handle error when getting latest achievement fails', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => sampleUser);
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenThrow(Exception('Achievement fetch error'));

        // Act & Assert
        expect(
          () async => await inAppOnboardingState.init('user123'),
          throwsException,
        );
      });

      test('should handle null current user', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act & Assert
        expect(
          () async => await inAppOnboardingState.init('user123'),
          throwsA(isA<TypeError>()),
        );
      });

      test('should set status to loaded during async operation', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        final future = inAppOnboardingState.init('user123');

        // Assert intermediate state
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);

        // Wait for completion
        await future;
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
      });

      test('should handle empty munro completions', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockMunroCompletionState.munroCompletions).thenReturn([]);
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockBulkMunroUpdateState.setStartingBulkMunroUpdateList = []).called(1);
      });

      test('should handle null achievement', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => null);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockAchievementsState.setCurrentAchievement = null).called(1);
      });

      test('should reset achievements state before setting current achievement', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        verifyInOrder([
          mockAchievementsState.reset(),
          mockUserAchievementsRepository.getLatestMunroChallengeAchievement(userId: 'user123'),
          mockAchievementsState.setCurrentAchievement = sampleAchievement,
        ]);
      });

      test('should clear munro filter string', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        verify(mockMunroState.setFilterString = '').called(1);
      });
    });

    group('setCurrentPage', () {
      test('should update current page', () {
        inAppOnboardingState.setCurrentPage = 1;
        expect(inAppOnboardingState.currentPage, 1);
      });

      test('should update current page to zero', () {
        inAppOnboardingState.setCurrentPage = 1;
        inAppOnboardingState.setCurrentPage = 0;
        expect(inAppOnboardingState.currentPage, 0);
      });

      test('should update current page to large number', () {
        inAppOnboardingState.setCurrentPage = 99;
        expect(inAppOnboardingState.currentPage, 99);
      });

      test('should handle negative page numbers', () {
        inAppOnboardingState.setCurrentPage = -1;
        expect(inAppOnboardingState.currentPage, -1);
      });
    });

    group('Edge Cases', () {
      test('should handle user with empty uid', () async {
        // Arrange
        final userWithEmptyUid = AppUser(
          uid: '',
          displayName: 'Test User',
          profilePictureURL: null,
          searchName: 'test user',
        );
        when(mockUserState.currentUser).thenReturn(userWithEmptyUid);
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(userId: '')).called(1);
      });

      test('should handle large list of munro completions', () async {
        // Arrange
        final largeMunroCompletionList = List.generate(
          1000,
          (index) => MunroCompletion(
            munroId: index,
            userId: 'user123',
            dateTimeCompleted: DateTime(2024, 1, index % 28 + 1),
          ),
        );
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockMunroCompletionState.munroCompletions).thenReturn(largeMunroCompletionList);
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockBulkMunroUpdateState.setStartingBulkMunroUpdateList = largeMunroCompletionList).called(1);
      });

      test('should handle multiple consecutive inits', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');
        await inAppOnboardingState.init('user123');
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockUserState.readUser(uid: 'user123')).called(3);
        verify(mockMunroCompletionState.loadUserMunroCompletions()).called(3);
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {
            AnalyticsProp.screenIndex: 0,
          },
        )).called(3);
      });

      test('should handle different user IDs', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');
        await inAppOnboardingState.init('user456');
        await inAppOnboardingState.init('user789');

        // Assert
        verify(mockUserState.readUser(uid: 'user123')).called(1);
        verify(mockUserState.readUser(uid: 'user456')).called(1);
        verify(mockUserState.readUser(uid: 'user789')).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when init completes', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        bool notified = false;
        inAppOnboardingState.addListener(() => notified = true);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting current page', () {
        bool notified = false;
        inAppOnboardingState.addListener(() => notified = true);

        inAppOnboardingState.setCurrentPage = 1;

        expect(notified, true);
      });

      test('should notify listeners multiple times during init', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        int notificationCount = 0;
        inAppOnboardingState.addListener(() => notificationCount++);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert - should notify at least twice (initial loaded status and final loaded status)
        expect(notificationCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners when page changes', () {
        int notificationCount = 0;
        inAppOnboardingState.addListener(() => notificationCount++);

        inAppOnboardingState.setCurrentPage = 1;
        inAppOnboardingState.setCurrentPage = 2;
        inAppOnboardingState.setCurrentPage = 3;

        expect(notificationCount, 3);
      });
    });

    group('Status Transitions', () {
      test('should transition from initial to loaded on successful init', () async {
        // Arrange
        expect(inAppOnboardingState.status, InAppOnboardingStatus.initial);
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
      });

      test('should set loaded status at start of init', () async {
        // Arrange
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async {
          // Verify status was set before readUser is called
          expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        });
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
      });

      test('should maintain loaded status throughout init', () async {
        // Arrange
        final statuses = <InAppOnboardingStatus>[];
        inAppOnboardingState.addListener(() {
          statuses.add(inAppOnboardingState.status);
        });

        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async => {});
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(statuses.every((status) => status == InAppOnboardingStatus.loaded), true);
      });
    });
  });
}
