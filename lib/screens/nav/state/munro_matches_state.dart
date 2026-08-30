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
  Set<String> _selectedMatchIds = {};
  Error _error = Error();

  MunroMatchesStatus get status => _status;
  List<PendingActivityReview> get pendingReviews => _pendingReviews;
  Set<String> get selectedMatchIds => _selectedMatchIds;
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

  void startReviewing(PendingActivityReview review) {
    _selectedMatchIds.clear();
    _selectedMatchIds.addAll(review.matches.map((match) => match.id));
    notifyListeners();
  }

  void toggleMatchSelection(String matchId) {
    if (_selectedMatchIds.contains(matchId)) {
      _selectedMatchIds.remove(matchId);
    } else {
      _selectedMatchIds.add(matchId);
    }
    notifyListeners();
  }

  Future<void> finalizeReview({
    required PendingActivityReview review,
    required Set<String> confirmedMatchIds,
  }) async {
    final confirmed = review.matches.where((m) => confirmedMatchIds.contains(m.id)).map((m) => m.id).toList();
    final rejected = review.matches.where((m) => !confirmedMatchIds.contains(m.id)).map((m) => m.id).toList();

    // Optimistic: let the UI move on immediately, reconcile with the server in the background.
    _pendingReviews = _pendingReviews.where((r) => r.activity.id != review.activity.id).toList();
    _selectedMatchIds = {};
    notifyListeners();

    try {
      await Future.wait([
        _munroMatchesRepository.updateMatchesStatus(matchIds: confirmed, status: MunroMatchStatus.confirmed),
        _munroMatchesRepository.updateMatchesStatus(matchIds: rejected, status: MunroMatchStatus.rejected),
      ]);
    } catch (error, stackTrace) {
      _logger.error('Failed to finalize activity review', error: error, stackTrace: stackTrace);
      _pendingReviews = [..._pendingReviews, review];
      setError = Error(message: 'Failed to update your munro matches');
    }
  }

  Future<void> rejectReviews({required List<PendingActivityReview> reviews}) async {
    final matchIds = reviews.expand((r) => r.matches.map((m) => m.id)).toList();

    // Optimistic: let the UI move on immediately, reconcile with the server in the background.
    _pendingReviews = _pendingReviews.where((r) => !reviews.contains(r)).toList();
    _selectedMatchIds = {};
    notifyListeners();

    try {
      await _munroMatchesRepository.updateMatchesStatus(matchIds: matchIds, status: MunroMatchStatus.rejected);
    } catch (error, stackTrace) {
      _logger.error('Failed to reject activity reviews', error: error, stackTrace: stackTrace);
      _pendingReviews = [..._pendingReviews, ...reviews];
      setError = Error(message: 'Failed to reject your munro matches');
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
