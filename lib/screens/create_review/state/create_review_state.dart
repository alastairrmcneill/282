import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class CreateReviewState extends ChangeNotifier {
  CreateReviewStatus _status = CreateReviewStatus.initial;
  Error _error = Error();
  List<Munro> _munrosToReview = [];
  Map<String, Map<String, dynamic>> _reviews = {};
  int _currentIndex = 0;
  int _currentMunroRating = 0;
  String _currentMunroReview = "";
  Review? _editingReview;

  CreateReviewStatus get status => _status;
  Error get error => _error;
  List<Munro> get munrosToReview => _munrosToReview;
  Map<String, Map<String, dynamic>> get reviews => _reviews;
  int get currentIndex => _currentIndex;
  int get currentMunroRating => _currentMunroRating;
  String get currentMunroReview => _currentMunroReview;
  Review? get editingReview => _editingReview;

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
    _reviews = {};
    for (Munro munro in munros) {
      _reviews[munro.id] = {"rating": 0, "review": ""};
    }
    notifyListeners();
  }

  set setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  set setCurrentMunroRating(int rating) {
    _currentMunroRating = rating;
    notifyListeners();
  }

  setMunroRating(String munroId, int rating) {
    if (_reviews.containsKey(munroId)) {
      _reviews[munroId]!["rating"] = rating;
    } else {
      _reviews[munroId] = {"rating": rating, "review": ""};
    }
    notifyListeners();
  }

  setMunroReview(String munroId, String review) {
    if (_reviews.containsKey(munroId)) {
      _reviews[munroId]!["review"] = review;
    } else {
      _reviews[munroId] = {"rating": 0, "review": review};
    }
    notifyListeners();
  }

  set setCurrentMunroReview(String review) {
    _currentMunroReview = review;
    notifyListeners();
  }

  set loadReview(Review review) {
    _editingReview = review;
    _currentMunroRating = review.rating;
    _currentMunroReview = review.text;
    notifyListeners();
  }

  reset() {
    _status = CreateReviewStatus.initial;
    _error = Error();
    _munrosToReview = [];
    _currentIndex = 0;
    _currentMunroRating = 0;
    _currentMunroReview = "";
    _editingReview = null;
  }
}

enum CreateReviewStatus { initial, loading, loaded, error }
