import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class MunroCompletionState extends ChangeNotifier {
  MunroCompletionsStatus _status = MunroCompletionsStatus.initial;
  Error _error = Error();
  List<MunroCompletion> _munroCompletions = [];

  MunroCompletionsStatus get status => _status;
  Error get error => _error;
  List<MunroCompletion> get munroCompletions => _munroCompletions;
  Set<int> get completedMunroIds => _munroCompletions.map((c) => c.munroId).toSet();

  set setMunroCompletions(List<MunroCompletion> munroCompletions) {
    _munroCompletions = munroCompletions;
    notifyListeners();
  }

  set setStatus(MunroCompletionsStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = MunroCompletionsStatus.error;
    _error = error;
    notifyListeners();
  }

  void reset() {
    _status = MunroCompletionsStatus.initial;
    _error = Error();
    _munroCompletions = [];
    notifyListeners();
  }
}

enum MunroCompletionsStatus { initial, loading, loaded, error }
