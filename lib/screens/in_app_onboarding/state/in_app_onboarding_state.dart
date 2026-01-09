import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/models/models.dart';
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
  final Analytics analytics;

  InAppOnboardingState(
    this.userState,
    this.munroCompletionState,
    this.bulkMunroUpdateState,
    this.achievementsState,
    this.userAchievementsRepository,
    this.munroState,
    this.appFlagsRepository,
    this.analytics,
  );

  InAppOnboardingStatus _status = InAppOnboardingStatus.initial;
  Error _error = Error();
  int _currentPage = 0;

  InAppOnboardingStatus get status => _status;
  Error get error => _error;
  int get currentPage => _currentPage;

  Future<void> init(String userId) async {
    _status = InAppOnboardingStatus.loaded;
    notifyListeners();

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

    if (munroCompletionState.munroCompletions.isEmpty && munroCompletionState.status != MunroCompletionsStatus.loaded) {
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
  }

  Future<void> completeOnboarding() async {
    _status = InAppOnboardingStatus.completing;
    notifyListeners();

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
  }

  set setCurrentPage(int pageIndex) {
    _currentPage = pageIndex;
    notifyListeners();
  }
}

enum InAppOnboardingStatus { initial, loading, loaded, completing, error }
