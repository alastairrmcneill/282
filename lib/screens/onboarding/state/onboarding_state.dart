import 'package:flutter/foundation.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';

class OnboardingState extends ChangeNotifier {
  final OnboardingRepository _onboardingRepository;
  final AppFlagsRepository _appFlagsRepository;
  bool _hascompletedOnboarding = false;

  OnboardingState(
    this._onboardingRepository,
    this._appFlagsRepository,
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
    } catch (e) {
      // Handle errors as needed
      debugPrint('Error loading onboarding data: $e');
    }
  }

  Future<void> markOnboardingCompleted() async {
    _hascompletedOnboarding = true;
    await _appFlagsRepository.setOnboardingCompleted(true);
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < totalPages - 1) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }
}
