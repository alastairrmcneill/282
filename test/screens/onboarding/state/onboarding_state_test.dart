import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/onboarding/state/onboarding_state.dart';

import 'onboarding_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  OnboardingRepository,
  AppFlagsRepository,
  Analytics,
  Logger,
])
void main() {
  late MockOnboardingRepository mockOnboardingRepository;
  late MockAppFlagsRepository mockAppFlagsRepository;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
  late OnboardingState onboardingState;

  late List<OnboardingFeedPost> sampleFeedPosts;
  late OnboardingTotals sampleTotals;
  late List<OnboardingAchievements> sampleAchievements;

  setUp(() {
    // Sample data for testing
    sampleFeedPosts = [
      OnboardingFeedPost(
        id: 'post1',
        displayName: 'John Doe',
        profilePictureUrl: 'https://example.com/john.jpg',
        munroName: 'Ben Nevis',
        dateTimeCreated: DateTime(2024, 1, 15),
      ),
      OnboardingFeedPost(
        id: 'post2',
        displayName: 'Jane Smith',
        profilePictureUrl: 'https://example.com/jane.jpg',
        munroName: 'Cairn Gorm',
        dateTimeCreated: DateTime(2024, 1, 16),
      ),
    ];

    sampleTotals = OnboardingTotals(
      totalUsers: 5000,
      totalMunroCompletions: 15000,
    );

    sampleAchievements = [
      OnboardingAchievements(
        name: 'First Peak',
        description: 'Climb your first Munro',
      ),
      OnboardingAchievements(
        name: 'Ten Munros',
        description: 'Climb 10 Munros',
      ),
    ];

    mockOnboardingRepository = MockOnboardingRepository();
    mockAppFlagsRepository = MockAppFlagsRepository();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();

    // Default mock behavior
    when(mockAppFlagsRepository.onboardingCompleted).thenReturn(false);
    when(mockOnboardingRepository.fetchFeedPosts()).thenAnswer((_) async => sampleFeedPosts);
    when(mockOnboardingRepository.fetchTotals()).thenAnswer((_) async => sampleTotals);
    when(mockOnboardingRepository.fetchAchievements()).thenAnswer((_) async => sampleAchievements);

    onboardingState = OnboardingState(
      mockOnboardingRepository,
      mockAppFlagsRepository,
      mockAnalytics,
      mockLogger,
    );
  });

  group('OnboardingState', () {
    group('Initial State', () {
      test('should have correct initial values when onboarding not completed', () {
        expect(onboardingState.hasCompletedOnboarding, false);
        expect(onboardingState.currentPage, 0);
        expect(onboardingState.isFirstPage, true);
        expect(onboardingState.isLastPage, false);
        expect(onboardingState.feedPosts, isEmpty);
        expect(onboardingState.totals, isNull);
        expect(onboardingState.achievements, isEmpty);
      });

      test('should have correct initial values when onboarding completed', () {
        when(mockAppFlagsRepository.onboardingCompleted).thenReturn(true);

        final state = OnboardingState(
          mockOnboardingRepository,
          mockAppFlagsRepository,
          mockAnalytics,
          mockLogger,
        );

        expect(state.hasCompletedOnboarding, true);
      });

      test('should read onboarding completed state from app flags', () {
        verify(mockAppFlagsRepository.onboardingCompleted).called(1);
      });
    });

    group('init', () {
      test('should load all data successfully', () async {
        // Act
        await onboardingState.init();
        // Wait for Future.wait to complete
        await Future.delayed(Duration.zero);

        // Assert
        expect(onboardingState.feedPosts, sampleFeedPosts);
        expect(onboardingState.totals, sampleTotals);
        expect(onboardingState.achievements, sampleAchievements);
        verify(mockOnboardingRepository.fetchFeedPosts()).called(1);
        verify(mockOnboardingRepository.fetchTotals()).called(1);
        verify(mockOnboardingRepository.fetchAchievements()).called(1);
      });

      test('should track analytics events on init', () async {
        // Act
        await onboardingState.init();

        // Assert
        verify(mockAnalytics.track(AnalyticsEvent.onboardingStarted)).called(1);
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {AnalyticsProp.screenIndex: 0},
        )).called(1);
      });

      test('should handle error when fetching feed posts fails', () async {
        // Arrange
        when(mockOnboardingRepository.fetchFeedPosts()).thenThrow(Exception('Network error'));

        // Act
        await onboardingState.init();
        await Future.delayed(Duration.zero);

        // Assert
        verify(mockLogger.error(
          'Failed to load onboarding data',
          error: anyNamed('error'),
          stackTrace: anyNamed('stackTrace'),
        )).called(1);
      });

      test('should handle error when fetching totals fails', () async {
        // Arrange
        when(mockOnboardingRepository.fetchTotals()).thenThrow(Exception('Database error'));

        // Act
        await onboardingState.init();
        await Future.delayed(Duration.zero);

        // Assert
        verify(mockLogger.error(
          'Failed to load onboarding data',
          error: anyNamed('error'),
          stackTrace: anyNamed('stackTrace'),
        )).called(1);
      });

      test('should handle error when fetching achievements fails', () async {
        // Arrange
        when(mockOnboardingRepository.fetchAchievements()).thenThrow(Exception('Server error'));

        // Act
        await onboardingState.init();
        await Future.delayed(Duration.zero);

        // Assert
        verify(mockLogger.error(
          'Failed to load onboarding data',
          error: anyNamed('error'),
          stackTrace: anyNamed('stackTrace'),
        )).called(1);
      });
    });

    group('markOnboardingCompleted', () {
      test('should mark onboarding as completed', () async {
        // Arrange
        when(mockAppFlagsRepository.setOnboardingCompleted(any)).thenAnswer((_) async => {});

        // Act
        await onboardingState.markOnboardingCompleted();

        // Assert
        expect(onboardingState.hasCompletedOnboarding, true);
        verify(mockAppFlagsRepository.setOnboardingCompleted(true)).called(1);
      });

      test('should track analytics event when marking completed', () async {
        // Arrange
        when(mockAppFlagsRepository.setOnboardingCompleted(any)).thenAnswer((_) async => {});

        // Act
        await onboardingState.markOnboardingCompleted();

        // Assert
        verify(mockAnalytics.track(AnalyticsEvent.onboardingCompleted)).called(1);
      });

      test('should notify listeners when marking completed', () async {
        // Arrange
        when(mockAppFlagsRepository.setOnboardingCompleted(any)).thenAnswer((_) async => {});
        bool notified = false;
        onboardingState.addListener(() => notified = true);

        // Act
        await onboardingState.markOnboardingCompleted();

        // Assert
        expect(notified, true);
      });
    });

    group('nextPage', () {
      test('should advance to next page when not on last page', () {
        // Act
        onboardingState.nextPage();

        // Assert
        expect(onboardingState.currentPage, 1);
      });

      test('should not advance beyond last page', () {
        // Arrange - move to last page
        onboardingState.goToPage(OnboardingState.totalPages - 1);
        reset(mockAnalytics); // Reset analytics to clear previous calls

        // Act
        onboardingState.nextPage();

        // Assert
        expect(onboardingState.currentPage, OnboardingState.totalPages - 1);
        verifyNever(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: anyNamed('props'),
        ));
      });

      test('should track analytics when advancing page', () {
        // Act
        onboardingState.nextPage();

        // Assert
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {AnalyticsProp.screenIndex: 1},
        )).called(1);
      });

      test('should notify listeners when advancing page', () {
        bool notified = false;
        onboardingState.addListener(() => notified = true);

        // Act
        onboardingState.nextPage();

        // Assert
        expect(notified, true);
      });

      test('should update isFirstPage and isLastPage correctly', () {
        // Initially on first page
        expect(onboardingState.isFirstPage, true);
        expect(onboardingState.isLastPage, false);

        // Move to middle page
        onboardingState.nextPage();
        expect(onboardingState.isFirstPage, false);
        expect(onboardingState.isLastPage, false);

        // Move to last page
        onboardingState.goToPage(OnboardingState.totalPages - 1);
        expect(onboardingState.isFirstPage, false);
        expect(onboardingState.isLastPage, true);
      });
    });

    group('previousPage', () {
      test('should go back to previous page when not on first page', () {
        // Arrange
        onboardingState.nextPage(); // Move to page 1
        reset(mockAnalytics);

        // Act
        onboardingState.previousPage();

        // Assert
        expect(onboardingState.currentPage, 0);
      });

      test('should not go below first page', () {
        // Already on first page (0)
        expect(onboardingState.currentPage, 0);

        // Act
        onboardingState.previousPage();

        // Assert
        expect(onboardingState.currentPage, 0);
      });

      test('should notify listeners when going back', () {
        // Arrange
        onboardingState.nextPage(); // Move to page 1
        bool notified = false;
        onboardingState.addListener(() => notified = true);

        // Act
        onboardingState.previousPage();

        // Assert
        expect(notified, true);
      });

      test('should not notify listeners when already on first page', () {
        bool notified = false;
        onboardingState.addListener(() => notified = true);

        // Act
        onboardingState.previousPage();

        // Assert
        expect(notified, false);
      });

      test('should not track analytics when going back', () {
        // Arrange
        onboardingState.nextPage(); // Move to page 1
        reset(mockAnalytics);

        // Act
        onboardingState.previousPage();

        // Assert
        verifyNever(mockAnalytics.track(any, props: anyNamed('props')));
      });
    });

    group('goToPage', () {
      test('should navigate to specific page within valid range', () {
        // Act
        onboardingState.goToPage(2);

        // Assert
        expect(onboardingState.currentPage, 2);
      });

      test('should not navigate to negative page number', () {
        // Arrange
        onboardingState.goToPage(2); // Start at page 2

        // Act
        onboardingState.goToPage(-1);

        // Assert
        expect(onboardingState.currentPage, 2); // Should remain unchanged
      });

      test('should not navigate beyond total pages', () {
        // Arrange
        onboardingState.goToPage(1); // Start at page 1

        // Act
        onboardingState.goToPage(OnboardingState.totalPages);

        // Assert
        expect(onboardingState.currentPage, 1); // Should remain unchanged
      });

      test('should navigate to first page (0)', () {
        // Arrange
        onboardingState.goToPage(2);

        // Act
        onboardingState.goToPage(0);

        // Assert
        expect(onboardingState.currentPage, 0);
      });

      test('should navigate to last page', () {
        // Act
        onboardingState.goToPage(OnboardingState.totalPages - 1);

        // Assert
        expect(onboardingState.currentPage, OnboardingState.totalPages - 1);
      });

      test('should notify listeners when navigating to valid page', () {
        bool notified = false;
        onboardingState.addListener(() => notified = true);

        // Act
        onboardingState.goToPage(2);

        // Assert
        expect(notified, true);
      });

      test('should not notify listeners when navigating to invalid page', () {
        bool notified = false;
        onboardingState.addListener(() => notified = true);

        // Act
        onboardingState.goToPage(-1);

        // Assert
        expect(notified, false);
      });

      test('should not track analytics when using goToPage', () {
        reset(mockAnalytics);

        // Act
        onboardingState.goToPage(2);

        // Assert
        verifyNever(mockAnalytics.track(any, props: anyNamed('props')));
      });
    });

    group('Getters', () {
      test('isFirstPage should return true only on first page', () {
        expect(onboardingState.isFirstPage, true);

        onboardingState.nextPage();
        expect(onboardingState.isFirstPage, false);

        onboardingState.previousPage();
        expect(onboardingState.isFirstPage, true);
      });

      test('isLastPage should return true only on last page', () {
        expect(onboardingState.isLastPage, false);

        onboardingState.goToPage(OnboardingState.totalPages - 1);
        expect(onboardingState.isLastPage, true);

        onboardingState.previousPage();
        expect(onboardingState.isLastPage, false);
      });

      test('currentPage should return correct page number', () {
        expect(onboardingState.currentPage, 0);

        onboardingState.nextPage();
        expect(onboardingState.currentPage, 1);

        onboardingState.nextPage();
        expect(onboardingState.currentPage, 2);
      });

      test('feedPosts should return loaded posts', () async {
        await onboardingState.init();
        await Future.delayed(Duration.zero);

        expect(onboardingState.feedPosts, sampleFeedPosts);
        expect(onboardingState.feedPosts.length, 2);
      });

      test('totals should return loaded totals', () async {
        await onboardingState.init();
        await Future.delayed(Duration.zero);

        expect(onboardingState.totals, sampleTotals);
        expect(onboardingState.totals?.totalUsers, 5000);
        expect(onboardingState.totals?.totalMunroCompletions, 15000);
      });

      test('achievements should return loaded achievements', () async {
        await onboardingState.init();
        await Future.delayed(Duration.zero);

        expect(onboardingState.achievements, sampleAchievements);
        expect(onboardingState.achievements.length, 2);
      });
    });

    group('Edge Cases', () {
      test('should handle totalPages constant correctly', () {
        expect(OnboardingState.totalPages, 4);
      });

      test('should handle rapid page navigation', () {
        onboardingState.nextPage();
        onboardingState.nextPage();
        onboardingState.previousPage();
        onboardingState.nextPage();
        onboardingState.goToPage(0);

        expect(onboardingState.currentPage, 0);
      });

      test('should handle empty feed posts from repository', () async {
        // Arrange
        when(mockOnboardingRepository.fetchFeedPosts()).thenAnswer((_) async => []);

        // Act
        await onboardingState.init();
        await Future.delayed(Duration.zero);

        // Assert
        expect(onboardingState.feedPosts, isEmpty);
      });

      test('should handle empty totals from repository', () async {
        // Arrange
        final emptyTotals = OnboardingTotals(
          totalUsers: 0,
          totalMunroCompletions: 0,
        );
        when(mockOnboardingRepository.fetchTotals()).thenAnswer((_) async => emptyTotals);

        // Act
        await onboardingState.init();
        await Future.delayed(Duration.zero);

        // Assert
        expect(onboardingState.totals?.totalUsers, 0);
        expect(onboardingState.totals?.totalMunroCompletions, 0);
      });

      test('should handle empty achievements from repository', () async {
        // Arrange
        when(mockOnboardingRepository.fetchAchievements()).thenAnswer((_) async => []);

        // Act
        await onboardingState.init();
        await Future.delayed(Duration.zero);

        // Assert
        expect(onboardingState.achievements, isEmpty);
      });

      test('should handle multiple consecutive nextPage calls at boundary', () {
        // Move to last page
        onboardingState.goToPage(OnboardingState.totalPages - 1);
        final pageBeforeAttempts = onboardingState.currentPage;

        // Try to advance multiple times
        onboardingState.nextPage();
        onboardingState.nextPage();
        onboardingState.nextPage();

        // Should still be on last page
        expect(onboardingState.currentPage, pageBeforeAttempts);
      });

      test('should handle multiple consecutive previousPage calls at boundary', () {
        // Already at first page
        expect(onboardingState.currentPage, 0);

        // Try to go back multiple times
        onboardingState.previousPage();
        onboardingState.previousPage();
        onboardingState.previousPage();

        // Should still be at first page
        expect(onboardingState.currentPage, 0);
      });

      test('should handle goToPage with boundary values', () {
        onboardingState.goToPage(OnboardingState.totalPages - 1);
        expect(onboardingState.currentPage, OnboardingState.totalPages - 1);

        onboardingState.goToPage(0);
        expect(onboardingState.currentPage, 0);
      });

      test('should handle large negative page numbers', () {
        onboardingState.goToPage(2);
        onboardingState.goToPage(-100);

        expect(onboardingState.currentPage, 2); // Should remain unchanged
      });

      test('should handle large positive page numbers', () {
        onboardingState.goToPage(2);
        onboardingState.goToPage(100);

        expect(onboardingState.currentPage, 2); // Should remain unchanged
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when init completes', () async {
        bool notified = false;
        onboardingState.addListener(() => notified = true);

        await onboardingState.init();
        await Future.delayed(Duration.zero);

        expect(notified, true);
      });

      test('should notify listeners when marking onboarding completed', () async {
        when(mockAppFlagsRepository.setOnboardingCompleted(any)).thenAnswer((_) async => {});

        bool notified = false;
        onboardingState.addListener(() => notified = true);

        await onboardingState.markOnboardingCompleted();

        expect(notified, true);
      });

      test('should notify listeners when calling nextPage', () {
        bool notified = false;
        onboardingState.addListener(() => notified = true);

        onboardingState.nextPage();

        expect(notified, true);
      });

      test('should notify listeners when calling previousPage from non-first page', () {
        onboardingState.nextPage(); // Move to page 1

        bool notified = false;
        onboardingState.addListener(() => notified = true);

        onboardingState.previousPage();

        expect(notified, true);
      });

      test('should notify listeners when calling goToPage with valid page', () {
        bool notified = false;
        onboardingState.addListener(() => notified = true);

        onboardingState.goToPage(2);

        expect(notified, true);
      });

      test('should not notify listeners when calling goToPage with invalid page', () {
        bool notified = false;
        onboardingState.addListener(() => notified = true);

        onboardingState.goToPage(-1);

        expect(notified, false);
      });

      test('should allow multiple listeners to be notified', () async {
        when(mockAppFlagsRepository.setOnboardingCompleted(any)).thenAnswer((_) async => {});

        int notificationCount = 0;
        onboardingState.addListener(() => notificationCount++);
        onboardingState.addListener(() => notificationCount++);
        onboardingState.addListener(() => notificationCount++);

        await onboardingState.markOnboardingCompleted();

        expect(notificationCount, 3);
      });

      test('should stop notifying removed listeners', () {
        int notificationCount = 0;
        void listener() => notificationCount++;

        onboardingState.addListener(listener);
        onboardingState.nextPage();
        expect(notificationCount, 1);

        onboardingState.removeListener(listener);
        onboardingState.nextPage();
        expect(notificationCount, 1); // Should not increase
      });
    });

    group('Analytics Integration', () {
      test('should track correct screen index for each page', () {
        reset(mockAnalytics);

        onboardingState.nextPage(); // Page 1
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {AnalyticsProp.screenIndex: 1},
        )).called(1);

        onboardingState.nextPage(); // Page 2
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {AnalyticsProp.screenIndex: 2},
        )).called(1);

        onboardingState.nextPage(); // Page 3
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {AnalyticsProp.screenIndex: 3},
        )).called(1);
      });

      test('should not track analytics for previousPage', () {
        onboardingState.nextPage();
        reset(mockAnalytics);

        onboardingState.previousPage();

        verifyNever(mockAnalytics.track(any, props: anyNamed('props')));
      });

      test('should not track analytics for goToPage', () {
        reset(mockAnalytics);

        onboardingState.goToPage(2);

        verifyNever(mockAnalytics.track(any, props: anyNamed('props')));
      });

      test('should track onboarding started and first screen on init', () async {
        reset(mockAnalytics);

        await onboardingState.init();

        verify(mockAnalytics.track(AnalyticsEvent.onboardingStarted)).called(1);
        verify(mockAnalytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {AnalyticsProp.screenIndex: 0},
        )).called(1);
      });

      test('should track onboarding completed', () async {
        when(mockAppFlagsRepository.setOnboardingCompleted(any)).thenAnswer((_) async => {});

        await onboardingState.markOnboardingCompleted();

        verify(mockAnalytics.track(AnalyticsEvent.onboardingCompleted)).called(1);
      });
    });
  });
}
