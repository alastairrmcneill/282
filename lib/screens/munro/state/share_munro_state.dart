import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';

class ShareState extends ChangeNotifier {
  final ShareLinkRepository _shareLinkRepository;
  final Analytics _analytics;
  final Logger _logger;

  ShareState(
    this._shareLinkRepository,
    this._analytics,
    this._logger,
  );

  ShareStatus _status = ShareStatus.initial;
  Error _error = Error();

  ShareStatus get status => _status;
  Error get error => _error;

  Future<String?> createAppLink() async {
    try {
      _analytics.track(AnalyticsEvent.appShared);
      return await _shareLinkRepository.createAppLink();
    } catch (error, stackTrace) {
      _logger.error('Failed to create share link', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Future<String?> createMunroLink({required int munroId, required String munroName}) async {
    try {
      _analytics.track(AnalyticsEvent.munroShared, props: {
        AnalyticsProp.munroId: munroId,
        AnalyticsProp.munroName: munroName,
      });
      return await _shareLinkRepository.createMunroLink(munroId);
    } catch (error, stackTrace) {
      _logger.error('Failed to create share link', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  set setStatus(ShareStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(
    Error error,
  ) {
    _status = ShareStatus.error;
    _error = error;
    _logger.error(error.message);
    notifyListeners();
  }

  void logError(Exception exception, StackTrace stackTrace) {
    _logger.error(exception.toString(), stackTrace: stackTrace);
  }

  void reset() {
    _status = ShareStatus.initial;
    _error = Error();
    notifyListeners();
  }
}

enum ShareStatus { initial, loading, loaded, error }
