import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class InAppOnboardingState extends ChangeNotifier {
  final UserState userState;
  final MunroCompletionState munroCompletionState;
  final BulkMunroUpdateState bulkMunroUpdateState;
  final MunroState munroState;
  final Analytics analytics;
  final Logger logger;

  InAppOnboardingState(
    this.userState,
    this.munroCompletionState,
    this.bulkMunroUpdateState,
    this.munroState,
    this.analytics,
    this.logger,
  );

  InAppOnboardingStatus _status = InAppOnboardingStatus.initial;
  Error _error = Error();

  InAppOnboardingStatus get status => _status;
  Error get error => _error;

  Future<void> init(String userId) async {
    _status = InAppOnboardingStatus.loading;
    notifyListeners();
    try {
      analytics.track(
        AnalyticsEvent.onboardingScreenViewed,
        props: {
          AnalyticsProp.stepNumber: 1,
          AnalyticsProp.stepName: 'munro_question',
          AnalyticsProp.source: 'in_app_onboarding',
        },
      );
      analytics.track(
        AnalyticsEvent.inAppOnboardingProgress,
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

      munroState.setFilterString = '';
      munroState.setBulkMunroUpdateFilterString = '';

      _status = InAppOnboardingStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      logger.error('InAppOnboardingState init error: $error', stackTrace: stackTrace);
      setError = Error(message: 'Failed to load onboarding data. Please try again.');
      notifyListeners();
    }
  }

  set setError(Error error) {
    _status = InAppOnboardingStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum InAppOnboardingStatus { initial, loading, loaded, completing, error }
