import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class ReviewsState extends ChangeNotifier {
  final ReviewsRepository _reviewsRepository;
  final MunroState _munroState;
  final UserState _userState;
  final Analytics _analytics;
  final Logger _logger;

  ReviewsState(
    this._reviewsRepository,
    this._munroState,
    this._userState,
    this._analytics,
    this._logger,
  );

  ReviewsStatus _status = ReviewsStatus.initial;
  Error _error = Error();
  List<Review> _reviews = [];
  MunroRatingsBreakdown? _ratingsBreakdown;

  ReviewsStatus get status => _status;
  Error get error => _error;
  List<Review> get reviews => _reviews;
  MunroRatingsBreakdown? get ratingsBreakdown => _ratingsBreakdown;

  Future<void> getMunroReviewsAndRatings(int munroId) async {
    List<String> blockedUsers = _userState.blockedUsers;

    setStatus = ReviewsStatus.loading;

    Future.wait([
      _reviewsRepository.readReviewsFromMunro(
        munroId: munroId,
        excludedAuthorIds: blockedUsers,
        offset: 0,
      ),
      _reviewsRepository.readRatingsBreakdownFromMunro(munroId: munroId),
    ]).then((results) {
      _reviews = results[0] as List<Review>;
      _ratingsBreakdown = results[1] as MunroRatingsBreakdown;

      setStatus = ReviewsStatus.loaded;
    }).catchError((error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue getting reviews for this munro. Please try again",
        code: error.toString(),
      );
    });
  }

  Future<void> paginateMunroReviews(int munroId) async {
    try {
      setStatus = ReviewsStatus.paginating;
      List<String> blockedUsers = _userState.blockedUsers;

      final reviews = await _reviewsRepository.readReviewsFromMunro(
        munroId: munroId,
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

      _analytics.track(
        AnalyticsEvent.deleteReview,
        props: {
          AnalyticsProp.reviewId: review.uid,
        },
      );
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

  void removeReview(Review review) {
    _reviews = _reviews.where((element) => element.uid != review.uid).toList();
    notifyListeners();
  }
}

enum ReviewsStatus { initial, loading, loaded, paginating, error }
