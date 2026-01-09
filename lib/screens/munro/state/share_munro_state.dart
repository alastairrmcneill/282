import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';

class ShareMunroState extends ChangeNotifier {
  final ShareLinkRepository _shareLinkRepository;
  final Analytics _analytics;
  final Logger _logger;

  ShareMunroState(
    this._shareLinkRepository,
    this._analytics,
    this._logger,
  );

  ShareMunroStatus _status = ShareMunroStatus.initial;
  Error _error = Error();

  ShareMunroStatus get status => _status;
  Error get error => _error;

  Future<String?> createShareLink({required int munroId, required String munroName}) async {
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

  set setStatus(ShareMunroStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(
    Error error,
  ) {
    _status = ShareMunroStatus.error;
    _error = error;
    _logger.error(error.message);
    notifyListeners();
  }

  void logError(Exception exception, StackTrace stackTrace) {
    _logger.error(exception.toString(), stackTrace: stackTrace);
  }

  void reset() {
    _status = ShareMunroStatus.initial;
    _error = Error();
    notifyListeners();
  }
}

enum ShareMunroStatus { initial, loading, loaded, error }
