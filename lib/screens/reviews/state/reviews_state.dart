import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class ReviewsState extends ChangeNotifier {
  ReviewsStatus _status = ReviewsStatus.initial;
  Error _error = Error();
  List<Review> _reviews = [];

  ReviewsStatus get status => _status;
  Error get error => _error;
  List<Review> get reviews => _reviews;

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
