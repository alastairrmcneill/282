import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class InAppOnboardingState extends ChangeNotifier {
  final UserState userState;
  final MunroCompletionState munroCompletionState;
  final BulkMunroUpdateState bulkMunroUpdateState;
  final AchievementsState achievementsState;
  final UserAchievementsRepository userAchievementsRepository;
  final MunroState munroState;
  final AppFlagsRepository appFlagsRepository;
  final SettingsState settingsState;
  final PushNotificationState pushNotificationState;
  final Analytics analytics;
  final Logger logger;

  InAppOnboardingState(
    this.userState,
    this.munroCompletionState,
    this.bulkMunroUpdateState,
    this.achievementsState,
    this.userAchievementsRepository,
    this.munroState,
    this.appFlagsRepository,
    this.settingsState,
    this.pushNotificationState,
    this.analytics,
    this.logger,
  );

  InAppOnboardingStatus _status = InAppOnboardingStatus.initial;
  Error _error = Error();
  int _currentPage = 0;

  InAppOnboardingStatus get status => _status;
  Error get error => _error;
  int get currentPage => _currentPage;

  Future<void> init(String userId) async {
    _status = InAppOnboardingStatus.loading;
    notifyListeners();
    try {
      analytics.track(
        AnalyticsEvent.onboardingScreenViewed,
        props: {
          AnalyticsProp.screenIndex: _currentPage,
        },
      );
      analytics.track(
        AnalyticsEvent.onboardingProgress,
        props: {
          AnalyticsProp.status: 'started',
        },
      );

      // User data and munro completions are now loaded in AuthState after sign-in
      // Only load if not already present (defensive check)
      if (userState.currentUser == null) {
        await userState.readUser(uid: userId);
      }

      if (munroCompletionState.munroCompletions.isEmpty &&
          munroCompletionState.status != MunroCompletionsStatus.loaded) {
        await munroCompletionState.loadUserMunroCompletions();
      }

      bulkMunroUpdateState.setStartingBulkMunroUpdateList = munroCompletionState.munroCompletions;

      achievementsState.reset();
      achievementsState.setCurrentAchievement = await userAchievementsRepository.getLatestMunroChallengeAchievement(
        userId: userState.currentUser!.uid ?? "",
      );

      munroState.setFilterString = '';

      _status = InAppOnboardingStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      logger.error('InAppOnboardingState init error: $error', stackTrace: stackTrace);
      setError = Error(message: 'Failed to load onboarding data. Please try again.');
      notifyListeners();
    }
  }

  /// Enables push notifications and syncs with the backend.
  /// Returns true if successful, false if OS permission denied.
  Future<bool> handleEnableNotifications() async {
    _status = InAppOnboardingStatus.completing;
    notifyListeners();

    try {
      await settingsState.setEnablePushNotifications(true);

      final granted = await pushNotificationState.enablePush();

      if (!granted) {
        await settingsState.setEnablePushNotifications(false);
        setError = Error(message: 'Please enable notifications in system settings to receive updates.');
        _status = InAppOnboardingStatus.loaded;
        notifyListeners();
        return false;
      }

      await analytics.track(
        AnalyticsEvent.onboardingProgress,
        props: {
          AnalyticsProp.status: 'notifications_enabled',
        },
      );

      return true;
    } catch (error, stackTrace) {
      setError = Error(message: 'An error occurred while enabling notifications.');
      logger.error('Error enabling notifications: $error', stackTrace: stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// Denies push notifications and clears FCM token from backend.
  Future<void> handleDenyNotifications() async {
    _status = InAppOnboardingStatus.completing;
    notifyListeners();

    try {
      await settingsState.setEnablePushNotifications(false);
      await pushNotificationState.disablePush();

      // Clear FCM token from database
      final user = userState.currentUser;
      if (user != null) {
        await userState.updateUser(appUser: user.copyWith(fcmToken: ''));
      }

      await analytics.track(
        AnalyticsEvent.onboardingProgress,
        props: {
          AnalyticsProp.status: 'notifications_denied',
        },
      );
    } catch (error, stackTrace) {
      logger.error('Error denying notifications: $error', stackTrace: stackTrace);
      setError = Error(message: 'An error occurred while processing your choice.');
      notifyListeners();
    }
  }

  /// Completes the onboarding process by saving achievements and munro completions.
  Future<void> completeOnboarding() async {
    _status = InAppOnboardingStatus.completing;
    notifyListeners();

    try {
      await achievementsState.setMunroChallenge();
      await munroCompletionState.addBulkCompletions(
        munroCompletions: bulkMunroUpdateState.addedMunroCompletions,
      );
      await appFlagsRepository.setShowBulkMunroDialog(false);
      await appFlagsRepository.setShowInAppOnboarding(userState.currentUser?.uid ?? "", false);
      await analytics.track(AnalyticsEvent.onboardingProgress, props: {
        AnalyticsProp.status: "completed",
        AnalyticsProp.munroCompletionsAdded: bulkMunroUpdateState.addedMunroCompletions.length,
        AnalyticsProp.munroChallengeCount: achievementsState.achievementFormCount,
      });

      _status = InAppOnboardingStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      logger.error('Error completing onboarding: $error', stackTrace: stackTrace);
      setError = Error(message: 'An error occurred while completing onboarding. Please try again.');
      notifyListeners();
    }
  }

  set setCurrentPage(int pageIndex) {
    _currentPage = pageIndex;
    notifyListeners();
  }

  set setError(Error error) {
    _status = InAppOnboardingStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum InAppOnboardingStatus { initial, loading, loaded, completing, error }
