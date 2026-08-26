// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class StravaActivityReviewState extends ChangeNotifier {
  final MunroMatchesRepository _munroMatchesRepository;
  final UserState _userState;
  final MunroCompletionState _munroCompletionState;
  final Analytics _analytics;
  final Logger _logger;

  StravaActivityReviewState(
    this._munroMatchesRepository,
    this._userState,
    this._munroCompletionState,
    this._analytics,
    this._logger,
  );

  MunroMatchesStatus _status = MunroMatchesStatus.initial;
  List<PendingActivityReview> _pendingReviews = [];
  Error _error = Error();

  MunroMatchesStatus get status => _status;
  List<PendingActivityReview> get pendingReviews => _pendingReviews;
  Error get error => _error;

  Future<List<PendingActivityReview>> loadPendingReviews() async {
    _status = MunroMatchesStatus.loading;
    notifyListeners();

    try {
      final userId = _userState.currentUser?.uid;
      if (userId == null) return [];

      final pendingReviews = await _munroMatchesRepository.getUsersPendingActivityReviews(userId: userId);

      _pendingReviews = pendingReviews;
      _status = MunroMatchesStatus.loaded;
      notifyListeners();
      return pendingReviews;
    } catch (error, stacktrace) {
      _logger.error('Failed to load pending matches', error: error, stackTrace: stacktrace);
      _status = MunroMatchesStatus.error;
      _error = Error(message: 'Failed to load pending matches');
      notifyListeners();
      rethrow;
    }
  }

  set setError(Error error) {
    _status = MunroMatchesStatus.error;
    _error = error;
    notifyListeners();
  }

  void reset() {
    _status = MunroMatchesStatus.initial;
    _error = Error();
    notifyListeners();
  }
}

enum MunroMatchesStatus { initial, loading, loaded, error }
