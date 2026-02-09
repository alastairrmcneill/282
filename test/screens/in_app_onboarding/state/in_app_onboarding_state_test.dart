import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/push/push.dart';
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
  SettingsState,
  PushNotificationState,
  Analytics,
  Logger,
])
void main() {
  late MockUserState mockUserState;
  late MockMunroCompletionState mockMunroCompletionState;
  late MockBulkMunroUpdateState mockBulkMunroUpdateState;
  late MockAchievementsState mockAchievementsState;
  late MockUserAchievementsRepository mockUserAchievementsRepository;
  late MockMunroState mockMunroState;
  late MockAppFlagsRepository mockAppFlagsRepository;
  late MockSettingsState mockSettingsState;
  late MockPushNotificationState mockPushNotificationState;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
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
    mockSettingsState = MockSettingsState();
    mockPushNotificationState = MockPushNotificationState();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();

    inAppOnboardingState = InAppOnboardingState(
      mockUserState,
      mockMunroCompletionState,
      mockBulkMunroUpdateState,
      mockAchievementsState,
      mockUserAchievementsRepository,
      mockMunroState,
      mockAppFlagsRepository,
      mockSettingsState,
      mockPushNotificationState,
      mockAnalytics,
      mockLogger,
    );

    // Default mock behavior
    when(mockUserState.currentUser).thenReturn(sampleUser);
    when(mockMunroCompletionState.munroCompletions).thenReturn(sampleMunroCompletions);
    when(mockMunroCompletionState.status).thenReturn(MunroCompletionsStatus.loaded);
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
      test('should initialize successfully when user is already loaded', () async {
        // Arrange
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verifyNever(mockUserState.readUser(uid: anyNamed('uid')));
        verifyNever(mockMunroCompletionState.loadUserMunroCompletions());
        verify(mockBulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions).called(1);
        verify(mockAchievementsState.reset()).called(1);
        verify(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(userId: 'user123')).called(1);
        verify(mockAchievementsState.setCurrentAchievement = sampleAchievement).called(1);
        verify(mockMunroState.setFilterString = '').called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should load user data when user is not present', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async {
          when(mockUserState.currentUser).thenReturn(sampleUser);
        });
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockUserState.readUser(uid: 'user123')).called(1);
        verifyNever(mockMunroCompletionState.loadUserMunroCompletions());
      });

      test('should load munro completions when empty and not loaded', () async {
        // Arrange
        when(mockMunroCompletionState.munroCompletions).thenReturn([]);
        when(mockMunroCompletionState.status).thenReturn(MunroCompletionsStatus.initial);
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenAnswer((_) async {
          when(mockMunroCompletionState.munroCompletions).thenReturn(sampleMunroCompletions);
        });
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockMunroCompletionState.loadUserMunroCompletions()).called(1);
      });

      test('should not load munro completions when already loaded', () async {
        // Arrange
        when(mockMunroCompletionState.munroCompletions).thenReturn([]);
        when(mockMunroCompletionState.status).thenReturn(MunroCompletionsStatus.loaded);
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verifyNever(mockMunroCompletionState.loadUserMunroCompletions());
      });

      test('should track analytics events on init', () async {
        // Arrange
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
          AnalyticsEvent.inAppOnboardingProgress,
          props: {
            AnalyticsProp.status: 'started',
          },
        )).called(1);
      });

      test('should handle error when reading user fails', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenThrow(Exception('User not found'));
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.error);
        expect(inAppOnboardingState.error.message, 'Failed to load onboarding data. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error when loading munro completions fails', () async {
        // Arrange
        when(mockMunroCompletionState.munroCompletions).thenReturn([]);
        when(mockMunroCompletionState.status).thenReturn(MunroCompletionsStatus.initial);
        when(mockMunroCompletionState.loadUserMunroCompletions()).thenThrow(Exception('Database error'));
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.error);
        expect(inAppOnboardingState.error.message, 'Failed to load onboarding data. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error when getting latest achievement fails', () async {
        // Arrange
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenThrow(Exception('Achievement fetch error'));

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.error);
        expect(inAppOnboardingState.error.message, 'Failed to load onboarding data. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleAchievement;
        });

        // Act
        final future = inAppOnboardingState.init('user123');

        // Assert intermediate state
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loading);

        // Wait for completion
        await future;
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
      });

      test('should handle null achievement', () async {
        // Arrange
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
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        verify(mockMunroState.setFilterString = '').called(1);
      });
    });

    group('handleEnableNotifications', () {
      test('should enable notifications successfully when granted', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async => {});
        when(mockPushNotificationState.enablePush()).thenAnswer((_) async => true);

        // Act
        final result = await inAppOnboardingState.handleEnableNotifications();

        // Assert
        expect(result, true);
        expect(inAppOnboardingState.status, InAppOnboardingStatus.completing);
        verify(mockSettingsState.setEnablePushNotifications(true)).called(1);
        verify(mockPushNotificationState.enablePush()).called(1);
        verify(mockAnalytics.track(
          AnalyticsEvent.inAppOnboardingProgress,
          props: {
            AnalyticsProp.status: 'notifications_enabled',
          },
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle permission denied gracefully', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async => {});
        when(mockPushNotificationState.enablePush()).thenAnswer((_) async => false);

        // Act
        final result = await inAppOnboardingState.handleEnableNotifications();

        // Assert
        expect(result, false);
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        expect(
            inAppOnboardingState.error.message, 'Please enable notifications in system settings to receive updates.');
        verify(mockSettingsState.setEnablePushNotifications(true)).called(1);
        verify(mockPushNotificationState.enablePush()).called(1);
        verify(mockSettingsState.setEnablePushNotifications(false)).called(1);
        verifyNever(mockAnalytics.track(
          AnalyticsEvent.inAppOnboardingProgress,
          props: anyNamed('props'),
        ));
      });

      test('should handle error when enabling push fails', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async => {});
        when(mockPushNotificationState.enablePush()).thenThrow(Exception('Push error'));

        // Act
        final result = await inAppOnboardingState.handleEnableNotifications();

        // Assert
        expect(result, false);
        expect(inAppOnboardingState.error.message, 'An error occurred while enabling notifications.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error when settings update fails', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenThrow(Exception('Settings error'));

        // Act
        final result = await inAppOnboardingState.handleEnableNotifications();

        // Assert
        expect(result, false);
        expect(inAppOnboardingState.error.message, 'An error occurred while enabling notifications.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to completing during async operation', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });
        when(mockPushNotificationState.enablePush()).thenAnswer((_) async => true);

        // Act
        final future = inAppOnboardingState.handleEnableNotifications();

        // Assert intermediate state
        expect(inAppOnboardingState.status, InAppOnboardingStatus.completing);

        // Wait for completion
        await future;
        expect(inAppOnboardingState.status, InAppOnboardingStatus.completing);
      });
    });

    group('handleDenyNotifications', () {
      test('should deny notifications successfully', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async => {});
        when(mockPushNotificationState.disablePush()).thenAnswer((_) async => true);

        // Act
        await inAppOnboardingState.handleDenyNotifications();

        // Assert
        verify(mockSettingsState.setEnablePushNotifications(false)).called(1);
        verify(mockPushNotificationState.disablePush()).called(1);
        verify(mockAnalytics.track(
          AnalyticsEvent.inAppOnboardingProgress,
          props: {
            AnalyticsProp.status: 'notifications_denied',
          },
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle null user gracefully', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async => {});
        when(mockPushNotificationState.disablePush()).thenAnswer((_) async => true);

        // Act
        await inAppOnboardingState.handleDenyNotifications();

        // Assert
        verify(mockSettingsState.setEnablePushNotifications(false)).called(1);
        verify(mockPushNotificationState.disablePush()).called(1);
        verify(mockAnalytics.track(
          AnalyticsEvent.inAppOnboardingProgress,
          props: {
            AnalyticsProp.status: 'notifications_denied',
          },
        )).called(1);
      });

      test('should handle error when disabling push fails', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async => {});
        when(mockPushNotificationState.disablePush()).thenThrow(Exception('Disable error'));

        // Act
        await inAppOnboardingState.handleDenyNotifications();

        // Assert
        expect(inAppOnboardingState.error.message, 'An error occurred while processing your choice.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to completing during async operation', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });
        when(mockPushNotificationState.disablePush()).thenAnswer((_) async => true);

        // Act
        final future = inAppOnboardingState.handleDenyNotifications();

        // Assert intermediate state
        expect(inAppOnboardingState.status, InAppOnboardingStatus.completing);

        // Wait for completion
        await future;
      });
    });

    group('completeOnboarding', () {
      test('should complete onboarding successfully', () async {
        // Arrange
        final addedCompletions = [sampleMunroCompletions.first];
        when(mockBulkMunroUpdateState.addedMunroCompletions).thenReturn(addedCompletions);
        when(mockAchievementsState.achievementFormCount).thenReturn(5);
        when(mockAchievementsState.setMunroChallenge()).thenAnswer((_) async => {});
        when(mockMunroCompletionState.addBulkCompletions(munroCompletions: anyNamed('munroCompletions')))
            .thenAnswer((_) async => {});
        when(mockAppFlagsRepository.setShowBulkMunroDialog(any)).thenAnswer((_) async => {});
        when(mockAppFlagsRepository.setShowInAppOnboarding(any, any)).thenAnswer((_) async => {});

        // Act
        await inAppOnboardingState.completeOnboarding();

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockAchievementsState.setMunroChallenge()).called(1);
        verify(mockMunroCompletionState.addBulkCompletions(munroCompletions: addedCompletions)).called(1);
        verify(mockAppFlagsRepository.setShowBulkMunroDialog(false)).called(1);
        verify(mockAppFlagsRepository.setShowInAppOnboarding('user123', false)).called(1);
        verify(mockAnalytics.track(
          AnalyticsEvent.inAppOnboardingProgress,
          props: {
            AnalyticsProp.status: 'completed',
            AnalyticsProp.munroCompletionsAdded: 1,
            AnalyticsProp.munroChallengeCount: 5,
          },
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error when setting munro challenge fails', () async {
        // Arrange
        when(mockBulkMunroUpdateState.addedMunroCompletions).thenReturn([]);
        when(mockAchievementsState.setMunroChallenge()).thenThrow(Exception('Achievement error'));

        // Act
        await inAppOnboardingState.completeOnboarding();

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.error);
        expect(inAppOnboardingState.error.message, 'An error occurred while completing onboarding. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error when adding bulk completions fails', () async {
        // Arrange
        when(mockBulkMunroUpdateState.addedMunroCompletions).thenReturn([]);
        when(mockAchievementsState.setMunroChallenge()).thenAnswer((_) async => {});
        when(mockMunroCompletionState.addBulkCompletions(munroCompletions: anyNamed('munroCompletions')))
            .thenThrow(Exception('Bulk add error'));

        // Act
        await inAppOnboardingState.completeOnboarding();

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.error);
        expect(inAppOnboardingState.error.message, 'An error occurred while completing onboarding. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error when updating app flags fails', () async {
        // Arrange
        when(mockBulkMunroUpdateState.addedMunroCompletions).thenReturn([]);
        when(mockAchievementsState.setMunroChallenge()).thenAnswer((_) async => {});
        when(mockMunroCompletionState.addBulkCompletions(munroCompletions: anyNamed('munroCompletions')))
            .thenAnswer((_) async => {});
        when(mockAppFlagsRepository.setShowBulkMunroDialog(any)).thenThrow(Exception('Flag error'));

        // Act
        await inAppOnboardingState.completeOnboarding();

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.error);
        expect(inAppOnboardingState.error.message, 'An error occurred while completing onboarding. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to completing during async operation', () async {
        // Arrange
        when(mockBulkMunroUpdateState.addedMunroCompletions).thenReturn([]);
        when(mockAchievementsState.achievementFormCount).thenReturn(0);
        when(mockAchievementsState.setMunroChallenge()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });
        when(mockMunroCompletionState.addBulkCompletions(munroCompletions: anyNamed('munroCompletions')))
            .thenAnswer((_) async => {});
        when(mockAppFlagsRepository.setShowBulkMunroDialog(any)).thenAnswer((_) async => {});
        when(mockAppFlagsRepository.setShowInAppOnboarding(any, any)).thenAnswer((_) async => {});

        // Act
        final future = inAppOnboardingState.completeOnboarding();

        // Assert intermediate state
        expect(inAppOnboardingState.status, InAppOnboardingStatus.completing);

        // Wait for completion
        await future;
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
      });

      test('should handle empty added munro completions', () async {
        // Arrange
        when(mockBulkMunroUpdateState.addedMunroCompletions).thenReturn([]);
        when(mockAchievementsState.achievementFormCount).thenReturn(0);
        when(mockAchievementsState.setMunroChallenge()).thenAnswer((_) async => {});
        when(mockMunroCompletionState.addBulkCompletions(munroCompletions: anyNamed('munroCompletions')))
            .thenAnswer((_) async => {});
        when(mockAppFlagsRepository.setShowBulkMunroDialog(any)).thenAnswer((_) async => {});
        when(mockAppFlagsRepository.setShowInAppOnboarding(any, any)).thenAnswer((_) async => {});

        // Act
        await inAppOnboardingState.completeOnboarding();

        // Assert
        verify(mockAnalytics.track(
          AnalyticsEvent.inAppOnboardingProgress,
          props: {
            AnalyticsProp.status: 'completed',
            AnalyticsProp.munroCompletionsAdded: 0,
            AnalyticsProp.munroChallengeCount: 0,
          },
        )).called(1);
      });
    });

    group('Setters', () {
      test('setCurrentPage should update current page', () {
        inAppOnboardingState.setCurrentPage = 1;
        expect(inAppOnboardingState.currentPage, 1);
      });

      test('setCurrentPage should update to zero', () {
        inAppOnboardingState.setCurrentPage = 1;
        inAppOnboardingState.setCurrentPage = 0;
        expect(inAppOnboardingState.currentPage, 0);
      });

      test('setCurrentPage should handle large numbers', () {
        inAppOnboardingState.setCurrentPage = 99;
        expect(inAppOnboardingState.currentPage, 99);
      });

      test('setCurrentPage should handle negative numbers', () {
        inAppOnboardingState.setCurrentPage = -1;
        expect(inAppOnboardingState.currentPage, -1);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        inAppOnboardingState.setError = error;

        expect(inAppOnboardingState.status, InAppOnboardingStatus.error);
        expect(inAppOnboardingState.error, error);
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
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');
        await inAppOnboardingState.init('user123');
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {
            AnalyticsProp.screenIndex: 0,
          },
        )).called(3);
      });

      test('should handle different user IDs', () async {
        // Arrange
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');
        await inAppOnboardingState.init('user456');
        await inAppOnboardingState.init('user789');

        // Assert - all calls use the same currentUser.uid from sampleUser
        verify(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(userId: 'user123')).called(3);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when init completes', () async {
        // Arrange
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

      test('should notify listeners when setting error', () {
        bool notified = false;
        inAppOnboardingState.addListener(() => notified = true);

        inAppOnboardingState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners when enabling notifications', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async => {});
        when(mockPushNotificationState.enablePush()).thenAnswer((_) async => true);

        bool notified = false;
        inAppOnboardingState.addListener(() => notified = true);

        // Act
        await inAppOnboardingState.handleEnableNotifications();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when denying notifications', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async => {});
        when(mockPushNotificationState.disablePush()).thenAnswer((_) async => true);
        when(mockUserState.updateUser(appUser: anyNamed('appUser'))).thenAnswer((_) async => {});

        bool notified = false;
        inAppOnboardingState.addListener(() => notified = true);

        // Act
        await inAppOnboardingState.handleDenyNotifications();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when completing onboarding', () async {
        // Arrange
        when(mockBulkMunroUpdateState.addedMunroCompletions).thenReturn([]);
        when(mockAchievementsState.achievementFormCount).thenReturn(0);
        when(mockAchievementsState.setMunroChallenge()).thenAnswer((_) async => {});
        when(mockMunroCompletionState.addBulkCompletions(munroCompletions: anyNamed('munroCompletions')))
            .thenAnswer((_) async => {});
        when(mockAppFlagsRepository.setShowBulkMunroDialog(any)).thenAnswer((_) async => {});
        when(mockAppFlagsRepository.setShowInAppOnboarding(any, any)).thenAnswer((_) async => {});

        bool notified = false;
        inAppOnboardingState.addListener(() => notified = true);

        // Act
        await inAppOnboardingState.completeOnboarding();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners multiple times during init', () async {
        // Arrange
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        int notificationCount = 0;
        inAppOnboardingState.addListener(() => notificationCount++);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert - should notify at least twice (loading and loaded)
        expect(notificationCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners when page changes multiple times', () {
        int notificationCount = 0;
        inAppOnboardingState.addListener(() => notificationCount++);

        inAppOnboardingState.setCurrentPage = 1;
        inAppOnboardingState.setCurrentPage = 2;
        inAppOnboardingState.setCurrentPage = 3;

        expect(notificationCount, 3);
      });
    });

    group('Status Transitions', () {
      test('should transition from initial to loading to loaded on successful init', () async {
        // Arrange
        expect(inAppOnboardingState.status, InAppOnboardingStatus.initial);
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
      });

      test('should transition to completing during handleEnableNotifications', () async {
        // Arrange
        when(mockSettingsState.setEnablePushNotifications(any)).thenAnswer((_) async {
          expect(inAppOnboardingState.status, InAppOnboardingStatus.completing);
        });
        when(mockPushNotificationState.enablePush()).thenAnswer((_) async => true);

        // Act
        await inAppOnboardingState.handleEnableNotifications();

        // Assert - status stays at completing on success
        expect(inAppOnboardingState.status, InAppOnboardingStatus.completing);
      });

      test('should transition to error on init failure', () async {
        // Arrange
        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenThrow(Exception('Test error'));

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.error);
      });

      test('should maintain status history during operations', () async {
        // Arrange
        final statuses = <InAppOnboardingStatus>[];
        inAppOnboardingState.addListener(() {
          statuses.add(inAppOnboardingState.status);
        });

        when(mockUserAchievementsRepository.getLatestMunroChallengeAchievement(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleAchievement);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(statuses, contains(InAppOnboardingStatus.loading));
        expect(statuses, contains(InAppOnboardingStatus.loaded));
        expect(statuses.last, InAppOnboardingStatus.loaded);
      });
    });
  });
}
