import 'package:flutter/foundation.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';

class OnboardingState extends ChangeNotifier {
  final OnboardingRepository _onboardingRepository;
  OnboardingState(this._onboardingRepository);

  int _currentPage = 0;
  static const int totalPages = 4;
  List<OnboardingFeedPostModel> _feedPosts = [];
  OnboardingTotalsModel? _totals;

  int get currentPage => _currentPage;

  bool get isFirstPage => _currentPage == 0;
  bool get isLastPage => _currentPage == totalPages - 1;

  List<OnboardingFeedPostModel> get feedPosts => _feedPosts;
  OnboardingTotalsModel? get totals => _totals;

  Future<void> init() async {
    try {
      _feedPosts = await _onboardingRepository.fetchFeedPosts();
      _totals = await _onboardingRepository.fetchTotals();
      notifyListeners();
    } catch (e) {
      // Handle errors as needed
      debugPrint('Error loading onboarding data: $e');
    }
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
