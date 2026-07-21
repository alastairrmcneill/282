import 'package:flutter/foundation.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';

class OnboardingState extends ChangeNotifier {
  final OnboardingRepository _onboardingRepository;
  final AppFlagsRepository _appFlagsRepository;
  final Analytics _analytics;
  final Logger _logger;
  bool _hascompletedOnboarding = false;

  OnboardingState(
    this._onboardingRepository,
    this._appFlagsRepository,
    this._analytics,
    this._logger,
  ) {
    _hascompletedOnboarding = _appFlagsRepository.onboardingCompleted;
  }

  int _currentPage = 0;
  int _maxPageReached = 0;
  static const int totalPages = 4;
  static const List<String> _stepNames = ['welcome', 'progress', 'achievement', 'munro_question'];
  // Distinct event per step so funnel reports can show step names as column
  // headers instead of one repeated event name with different filters.
  static const List<String> _stepEventNames = [
    AnalyticsEvent.onboardingWelcomeViewed,
    AnalyticsEvent.onboardingProgressViewed,
    AnalyticsEvent.onboardingAchievementViewed,
    AnalyticsEvent.onboardingMunroQuestionViewed,
  ];
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
      Future.wait([
        _onboardingRepository.fetchFeedPosts(),
        _onboardingRepository.fetchTotals(),
        _onboardingRepository.fetchAchievements(),
      ]).then((results) {
        _feedPosts = results[0] as List<OnboardingFeedPost>;
        _totals = results[1] as OnboardingTotals;
        _achievements = results[2] as List<OnboardingAchievements>;
        notifyListeners();
      });
      _analytics.track(AnalyticsEvent.onboardingStarted);
      _analytics.track(
        AnalyticsEvent.onboardingScreenViewed,
        props: {
          AnalyticsProp.stepNumber: 1,
          AnalyticsProp.stepName: _stepNames[0],
          AnalyticsProp.source: 'first_run_onboarding',
        },
      );
      _analytics.track(_stepEventNames[0]);
    } catch (error, stackTrace) {
      _logger.error(
        "Failed to load onboarding data",
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> markOnboardingCompleted({required String branch}) async {
    _hascompletedOnboarding = true;
    await _appFlagsRepository.setOnboardingCompleted(true);
    notifyListeners();
    _analytics.track(AnalyticsEvent.onboardingCompleted, props: {AnalyticsProp.branch: branch});
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

  // The real PageView (onboarding_screen.dart) drives navigation entirely
  // through PageController.next/previousPage(), which fires onPageChanged ->
  // goToPage() - nextPage()/previousPage() above are never hit in production,
  // only by tests. Tracking lives here so every screen change is captured
  // regardless of swipe direction or entry point.
  //
  // Analytics only fires the first time a page is reached (page > _maxPageReached)
  // so swiping back and forth doesn't inflate view counts for already-seen steps.
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
            AnalyticsProp.source: 'first_run_onboarding',
          },
        );
        _analytics.track(_stepEventNames[page]);
      }
    }
  }
}
