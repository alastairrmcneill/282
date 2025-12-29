import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class BulkMunroUpdateState extends ChangeNotifier {
  BulkMunroUpdateStatus _status = BulkMunroUpdateStatus.initial;
  Error _error = Error();
  List<MunroCompletion> _startingBulkMunroUpdateList = [];
  List<MunroCompletion> _addedMunroCompletions = [];

  BulkMunroUpdateStatus get status => _status;
  Error get error => _error;
  List<MunroCompletion> get startingBulkMunroUpdateList => _startingBulkMunroUpdateList;
  List<MunroCompletion> get bulkMunroUpdateList => [..._startingBulkMunroUpdateList, ..._addedMunroCompletions];
  List<MunroCompletion> get addedMunroCompletions => _addedMunroCompletions;

  set setStatus(BulkMunroUpdateStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = BulkMunroUpdateStatus.error;
    _error = error;
    notifyListeners();
  }

  set setStartingBulkMunroUpdateList(List<MunroCompletion> bulkMunroUpdateList) {
    _startingBulkMunroUpdateList = bulkMunroUpdateList;
    _addedMunroCompletions = [];
    notifyListeners();
  }

  void addMunroCompleted(MunroCompletion munroCompletion) {
    _addedMunroCompletions.add(munroCompletion);
    notifyListeners();
  }

  void updateMunroCompleted(MunroCompletion munroCompletion) {
    _addedMunroCompletions.removeWhere((element) => element.munroId == munroCompletion.munroId);
    _addedMunroCompletions.add(munroCompletion);

    notifyListeners();
  }

  void removeMunroCompletion(int id) {
    _addedMunroCompletions.removeWhere((element) => element.munroId == id);
    notifyListeners();
  }
}

enum BulkMunroUpdateStatus { initial, loading, loaded, error }
