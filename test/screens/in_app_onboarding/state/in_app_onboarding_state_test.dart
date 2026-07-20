import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'in_app_onboarding_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  UserState,
  MunroCompletionState,
  BulkMunroUpdateState,
  MunroState,
  Analytics,
  Logger,
])
void main() {
  late MockUserState mockUserState;
  late MockMunroCompletionState mockMunroCompletionState;
  late MockBulkMunroUpdateState mockBulkMunroUpdateState;
  late MockMunroState mockMunroState;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
  late InAppOnboardingState inAppOnboardingState;

  late AppUser sampleUser;
  late List<MunroCompletion> sampleMunroCompletions;

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

    mockUserState = MockUserState();
    mockMunroCompletionState = MockMunroCompletionState();
    mockBulkMunroUpdateState = MockBulkMunroUpdateState();
    mockMunroState = MockMunroState();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();

    inAppOnboardingState = InAppOnboardingState(
      mockUserState,
      mockMunroCompletionState,
      mockBulkMunroUpdateState,
      mockMunroState,
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
      });
    });

    group('init', () {
      test('should initialize successfully when user is already loaded', () async {
        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verifyNever(mockUserState.readUser(uid: anyNamed('uid')));
        verifyNever(mockMunroCompletionState.loadUserMunroCompletions());
        verify(mockBulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions).called(1);
        verify(mockMunroState.setFilterString = '').called(1);
        verify(mockMunroState.setBulkMunroUpdateFilterString = '').called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should load user data when user is not present', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async {
          when(mockUserState.currentUser).thenReturn(sampleUser);
        });

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

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verifyNever(mockMunroCompletionState.loadUserMunroCompletions());
      });

      test('should track analytics events on init', () async {
        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {
            AnalyticsProp.stepNumber: 1,
            AnalyticsProp.stepName: 'munro_question',
            AnalyticsProp.source: 'in_app_onboarding',
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

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.error);
        expect(inAppOnboardingState.error.message, 'Failed to load onboarding data. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          when(mockUserState.currentUser).thenReturn(sampleUser);
        });

        // Act
        final future = inAppOnboardingState.init('user123');

        // Assert intermediate state
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loading);

        // Wait for completion
        await future;
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
      });

      test('should clear munro and bulk update filter strings', () async {
        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        verify(mockMunroState.setFilterString = '').called(1);
        verify(mockMunroState.setBulkMunroUpdateFilterString = '').called(1);
      });
    });

    group('Setters', () {
      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        inAppOnboardingState.setError = error;

        expect(inAppOnboardingState.status, InAppOnboardingStatus.error);
        expect(inAppOnboardingState.error, error);
      });
    });

    group('Edge Cases', () {
      test('should read user with the given uid when current user is missing', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenAnswer((_) async {
          when(mockUserState.currentUser).thenReturn(sampleUser);
        });

        // Act
        await inAppOnboardingState.init('');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockUserState.readUser(uid: '')).called(1);
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

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockBulkMunroUpdateState.setStartingBulkMunroUpdateList = largeMunroCompletionList).called(1);
      });

      test('should handle multiple consecutive inits', () async {
        // Act
        await inAppOnboardingState.init('user123');
        await inAppOnboardingState.init('user123');
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {
            AnalyticsProp.stepNumber: 1,
            AnalyticsProp.stepName: 'munro_question',
            AnalyticsProp.source: 'in_app_onboarding',
          },
        )).called(3);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when init completes', () async {
        // Arrange
        bool notified = false;
        inAppOnboardingState.addListener(() => notified = true);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting error', () {
        bool notified = false;
        inAppOnboardingState.addListener(() => notified = true);

        inAppOnboardingState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners multiple times during init', () async {
        // Arrange
        int notificationCount = 0;
        inAppOnboardingState.addListener(() => notificationCount++);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert - should notify at least twice (loading and loaded)
        expect(notificationCount, greaterThanOrEqualTo(2));
      });
    });

    group('Status Transitions', () {
      test('should transition from initial to loading to loaded on successful init', () async {
        // Arrange
        expect(inAppOnboardingState.status, InAppOnboardingStatus.initial);

        // Act
        await inAppOnboardingState.init('user123');

        // Assert
        expect(inAppOnboardingState.status, InAppOnboardingStatus.loaded);
      });

      test('should transition to error on init failure', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockUserState.readUser(uid: anyNamed('uid'))).thenThrow(Exception('Test error'));

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
