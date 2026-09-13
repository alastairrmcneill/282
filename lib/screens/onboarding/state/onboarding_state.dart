import 'package:flutter/foundation.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class OnboardingState extends ChangeNotifier {
  final OnboardingRepository _onboardingRepository;
  final AppFlagsRepository _appFlagsRepository;
  final AuthState _authState;
  final StravaState _stravaState;
  final Analytics _analytics;
  final Logger _logger;
  bool _hascompletedOnboarding = false;

  OnboardingState(
    this._onboardingRepository,
    this._appFlagsRepository,
    this._authState,
    this._stravaState,
    this._analytics,
    this._logger,
  ) {
    _hascompletedOnboarding = _appFlagsRepository.onboardingCompleted;
  }

  int _currentPage = 0;
  int _maxPageReached = 0;
  static const int totalPages = 2;
  static const List<String> _stepNames = ['welcome', 'munro_question'];
  List<OnboardingFeedPost> _feedPosts = [];
  OnboardingTotals? _totals;
  List<OnboardingAchievements> _achievements = [];

  bool get hasCompletedOnboarding => _hascompletedOnboarding;

  int get currentPage => _currentPage;

  String get currentStepName => _stepNames[_currentPage];

  bool get isFirstPage => _currentPage == 0;
  bool get isLastPage => _currentPage == totalPages - 1;

  List<OnboardingFeedPost> get feedPosts => _feedPosts;
  OnboardingTotals? get totals => _totals;
  List<OnboardingAchievements> get achievements => _achievements;

  Future<void> init() async {
    try {
      _totals = await _onboardingRepository.fetchTotals();
      notifyListeners();
      _analytics.track(
        AnalyticsEvent.onboardingScreenViewed,
        props: {
          AnalyticsProp.stepNumber: 1,
          AnalyticsProp.stepName: _stepNames[0],
          AnalyticsProp.source: AnalyticsSource.firstRunOnboarding,
        },
      );
    } catch (error, stackTrace) {
      _logger.error(
        "Failed to load onboarding data",
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> markOnboardingCompleted({
    required String branch,
    int munrosLogged = 0,
    bool notificationsEnabled = false,
  }) async {
    _hascompletedOnboarding = true;
    await _appFlagsRepository.setOnboardingCompleted(true);
    notifyListeners();
    _analytics.track(
      AnalyticsEvent.onboardingCompleted,
      props: {
        AnalyticsProp.branch: branch,
        AnalyticsProp.source: AnalyticsSource.firstRunOnboarding,
        AnalyticsProp.munrosLogged: munrosLogged,
        AnalyticsProp.notificationsEnabled: notificationsEnabled,
      },
    );
  }

  Future<StravaConnectionStatus> connectWithStrava() async {
    // Create annonymous account
    final authResult = await _authState.signInAnonymously();
    if (!authResult.success) {
      _logger.error("Failed to create anonymous account");
      return StravaConnectionStatus.error;
    }

    return _stravaState.connectWithStrava(userId: authResult.userId ?? "");
  }

  void nextPage() {
    if (_currentPage < totalPages - 1) {
      goToPage(_currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      goToPage(_currentPage - 1);
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      _currentPage = page;
      notifyListeners();
      if (page > _maxPageReached) {
        _maxPageReached = page;
        _analytics.track(
          AnalyticsEvent.onboardingScreenViewed,
          props: {
            AnalyticsProp.stepNumber: page + 1,
            AnalyticsProp.stepName: _stepNames[page],
            AnalyticsProp.source: AnalyticsSource.firstRunOnboarding,
          },
        );
      }
    }
  }
}
