import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class ReviewsState extends ChangeNotifier {
  final ReviewsRepository _reviewsRepository;
  final MunroState _munroState;
  final UserState _userState;
  final Logger _logger;

  ReviewsState(
    this._reviewsRepository,
    this._munroState,
    this._userState,
    this._logger,
  );

  ReviewsStatus _status = ReviewsStatus.initial;
  Error _error = Error();
  List<Review> _reviews = [];

  ReviewsStatus get status => _status;
  Error get error => _error;
  List<Review> get reviews => _reviews;

  Future<void> getMunroReviews() async {
    List<String> blockedUsers = _userState.blockedUsers;

    try {
      setStatus = ReviewsStatus.loading;

      // Get reviews
      final reviews = await _reviewsRepository.readReviewsFromMunro(
        munroId: _munroState.selectedMunro?.id ?? 0,
        excludedAuthorIds: blockedUsers,
        offset: 0,
      );

      setReviews = reviews;
      setStatus = ReviewsStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue getting reviews for this munro. Please try again",
        code: error.toString(),
      );
    }
  }

  Future<void> paginateMunroReviews() async {
    try {
      setStatus = ReviewsStatus.paginating;
      List<String> blockedUsers = _userState.blockedUsers;

      final reviews = await _reviewsRepository.readReviewsFromMunro(
        munroId: _munroState.selectedMunro?.id ?? 0,
        excludedAuthorIds: blockedUsers,
        offset: _reviews.length,
      );

      addReviews = reviews;
      setStatus = ReviewsStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue getting reviews for this munro. Please try again",
        code: error.toString(),
      );
    }
  }

  Future<void> deleteReview({required Review review}) async {
    try {
      await _reviewsRepository.delete(uid: review.uid!);
      _munroState.loadMunros();

      removeReview(review);
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue deleting your review. Please try again",
        code: error.toString(),
      );
    }
  }

  set setStatus(ReviewsStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = ReviewsStatus.error;
    _error = error;
    notifyListeners();
  }

  set setReviews(List<Review> reviews) {
    _reviews = reviews;
    notifyListeners();
  }

  set addReviews(List<Review> reviews) {
    _reviews.addAll(reviews);
    notifyListeners();
  }

  set replaceReview(Review replaceReview) {
    int index = _reviews.indexWhere((review) => review.uid == replaceReview.uid);

    if (index != -1) {
      _reviews[index] = replaceReview;
      notifyListeners();
    }
  }

  removeReview(Review review) {
    _reviews = _reviews.where((element) => element.uid != review.uid).toList();
    notifyListeners();
  }
}

enum ReviewsStatus { initial, loading, loaded, paginating, error }
