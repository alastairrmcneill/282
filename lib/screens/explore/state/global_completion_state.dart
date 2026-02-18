import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';

class GlobalCompletionState extends ChangeNotifier {
  final GlobalCompletionCountRepository _globalCompletionCountRepository;
  final LocalStorageRepository _localStorageRepository;
  final Logger _logger;

  GlobalCompletionState(
    this._globalCompletionCountRepository,
    this._localStorageRepository,
    this._logger,
  );

  GlobalCompletionStatus _status = GlobalCompletionStatus.initial;
  Error _error = Error();
  int _globalCompletionCount = 0;

  GlobalCompletionStatus get status => _status;
  Error get error => _error;
  int get globalCompletionCount => _globalCompletionCount;

  void loadFromLocalStorage() {
    try {
      final count = _localStorageRepository.getGlobalCompletionCount();
      if (count == -1 || count == null) {
        setError = Error(message: 'No local data available');
        return;
      }
      _globalCompletionCount = count;
    } catch (error, stackTrace) {
      _logger.error('Error loading global completion count from local storage', error: error, stackTrace: stackTrace);
      setError = Error(message: 'Failed to load global completion count from local storage');
    }
  }

  Future<void> fetchGlobalCompletionCount() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      setStatus = GlobalCompletionStatus.loading;
      final count = await _globalCompletionCountRepository.getGlobalCompletionCount();

      if (count == -1) {
        setError = Error(message: 'No remote data available');
        return;
      }

      _globalCompletionCount = count;
      await _localStorageRepository.setGlobalCompletionCount(count);
      setStatus = GlobalCompletionStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error('Error fetching global completion count', error: error, stackTrace: stackTrace);
      setError = Error(message: 'Failed to load global completion count');
    }
  }

  set setStatus(GlobalCompletionStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = GlobalCompletionStatus.error;
    _error = error;
    notifyListeners();
  }

  void reset() {
    _status = GlobalCompletionStatus.initial;
    _error = Error();
    notifyListeners();
  }
}

enum GlobalCompletionStatus { initial, loading, loaded, error }
