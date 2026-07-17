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
  static const int totalPages = 4;
  List<OnboardingFeedPost> _feedPosts = [];
  OnboardingTotals? _totals;
  List<OnboardingAchievements> _achievements = [];

  bool get hasCompletedOnboarding => _hascompletedOnboarding;

  int get currentPage => _currentPage;

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
        props: {AnalyticsProp.screenIndex: 0, AnalyticsProp.source: 'first_run_onboarding'},
      );
    } catch (error, stackTrace) {
      _logger.error(
        "Failed to load onboarding data",
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> markOnboardingCompleted() async {
    _hascompletedOnboarding = true;
    await _appFlagsRepository.setOnboardingCompleted(true);
    notifyListeners();
    _analytics.track(AnalyticsEvent.onboardingCompleted);
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
  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      _currentPage = page;
      notifyListeners();
      _analytics.track(
        AnalyticsEvent.onboardingScreenViewed,
        props: {AnalyticsProp.screenIndex: _currentPage, AnalyticsProp.source: 'first_run_onboarding'},
      );
    }
  }
}
