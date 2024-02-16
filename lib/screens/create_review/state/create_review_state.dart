import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class CreateReviewState extends ChangeNotifier {
  CreateReviewStatus _status = CreateReviewStatus.initial;
  Error _error = Error();
  List<Munro> _munrosToReview = [];
  int _currentIndex = 0;

  CreateReviewStatus get status => _status;
  Error get error => _error;
  List<Munro> get munrosToReview => _munrosToReview;
  int get currentIndex => _currentIndex;

  set setStatus(CreateReviewStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = CreateReviewStatus.error;
    _error = error;
    notifyListeners();
  }

  set setMunrosToReview(List<Munro> munros) {
    _munrosToReview = munros;
    notifyListeners();
  }

  set setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  reset() {
    _status = CreateReviewStatus.initial;
    _error = Error();
    _munrosToReview = [];
    _currentIndex = 0;
  }
}

enum CreateReviewStatus { initial, loading, loaded, error }
