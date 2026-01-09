import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';

class TemplateState extends ChangeNotifier {
  final Logger _logger;

  TemplateState(
    this._logger,
  );

  TemplateStatus _status = TemplateStatus.initial;
  Error _error = Error();

  TemplateStatus get status => _status;
  Error get error => _error;

  set setStatus(TemplateStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = TemplateStatus.error;
    _error = error;
    _logger.error(error.message);
    notifyListeners();
  }

  void logError(Exception exception, StackTrace stackTrace) {
    _logger.error(exception.toString(), stackTrace: stackTrace);
  }

  void reset() {
    _status = TemplateStatus.initial;
    _error = Error();
    notifyListeners();
  }
}

enum TemplateStatus { initial, loading, loaded, error }
