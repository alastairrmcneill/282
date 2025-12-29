import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class CreateReviewState extends ChangeNotifier {
  final ReviewsRepository _reviewsRepository;
  final UserState _userState;
  final MunroState _munroState;
  final Logger _logger;
  CreateReviewState(
    this._reviewsRepository,
    this._userState,
    this._munroState,
    this._logger,
  );
  CreateReviewStatus _status = CreateReviewStatus.initial;
  Error _error = Error();
  List<Munro> _munrosToReview = [];
  Map<int, Map<String, dynamic>> _reviews = {};
  int _currentIndex = 0;
  int _currentMunroRating = 0;
  String _currentMunroReview = "";
  Review? _editingReview;

  CreateReviewStatus get status => _status;
  Error get error => _error;
  List<Munro> get munrosToReview => _munrosToReview;
  Map<int, Map<String, dynamic>> get reviews => _reviews;
  int get currentIndex => _currentIndex;
  int get currentMunroRating => _currentMunroRating;
  String get currentMunroReview => _currentMunroReview;
  Review? get editingReview => _editingReview;

  Future<void> createReview() async {
    try {
      setStatus = CreateReviewStatus.loading;

      for (var key in _reviews.keys) {
        Review review = Review(
          authorId: _userState.currentUser?.uid ?? "",
          authorDisplayName: _userState.currentUser?.displayName ?? "",
          authorProfilePictureURL: _userState.currentUser?.profilePictureURL,
          dateTime: DateTime.now().toUtc(),
          rating: _reviews[key]![ReviewFields.rating] ?? 0,
          text: _reviews[key]!["review"] ?? "",
          munroId: key,
        );

        // Upload to database

        await _reviewsRepository.create(review: review);
      }

      _munroState.loadMunros();

      setStatus = CreateReviewStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue posting your review. Please try again",
        code: error.toString(),
      );
    }
  }

  Future editReview({
    required void Function(Review newReview) onReviewUpdated,
  }) async {
    try {
      setStatus = CreateReviewStatus.loading;

      Review review = _editingReview!;

      Review newReview = review.copyWith(
        rating: _currentMunroRating,
        text: _currentMunroReview,
      );

      // Send to database
      await _reviewsRepository.update(review: newReview);

      onReviewUpdated(newReview);
      _munroState.loadMunros();
      setStatus = CreateReviewStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue editing your review. Please try again",
        code: error.toString(),
      );
    }
  }

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

  setMunroRating(int munroId, int rating) {
    if (_reviews.containsKey(munroId)) {
      _reviews[munroId]!["rating"] = rating;
    } else {
      _reviews[munroId] = {"rating": rating, "review": ""};
    }
    notifyListeners();
  }

  setMunroReview(int munroId, String review) {
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
