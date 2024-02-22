import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class ReviewsState extends ChangeNotifier {
  ReviewsStatus _status = ReviewsStatus.initial;
  Error _error = Error();
  List<Review> _reviews = [];
  ReviewsSource _source = ReviewsSource.munro;

  ReviewsStatus get status => _status;
  Error get error => _error;
  List<Review> get reviews => _reviews;
  ReviewsSource get source => _source;

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

  set setSource(ReviewsSource source) {
    _source = source;
    notifyListeners();
  }
}

enum ReviewsStatus { initial, loading, loaded, paginating, error }

enum ReviewsSource { munro, profile }
