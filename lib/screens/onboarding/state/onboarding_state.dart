import 'package:flutter/foundation.dart';

class OnboardingState extends ChangeNotifier {
  int _currentPage = 0;
  static const int totalPages = 5;

  int get currentPage => _currentPage;

  bool get isFirstPage => _currentPage == 0;
  bool get isLastPage => _currentPage == totalPages - 1;

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
