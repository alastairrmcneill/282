import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class BulkMunroUpdateState extends ChangeNotifier {
  BulkMunroUpdateStatus _status = BulkMunroUpdateStatus.initial;
  Error _error = Error();
  List<Map<String, dynamic>> _bulkMunroUpdateList = personalMunroDataExample;

  BulkMunroUpdateStatus get status => _status;
  Error get error => _error;
  List<Map<String, dynamic>> get bulkMunroUpdateList => _bulkMunroUpdateList;

  set setStatus(BulkMunroUpdateStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = BulkMunroUpdateStatus.error;
    _error = error;
    notifyListeners();
  }

  set setBulkMunroUpdateList(List<Map<String, dynamic>> bulkMunroUpdateList) {
    _bulkMunroUpdateList = bulkMunroUpdateList;
    notifyListeners();
  }

  set setMunro(Map<String, dynamic> munro) {
    int index = _bulkMunroUpdateList.indexWhere((element) => element[MunroFields.id] == munro[MunroFields.id]);
    if (index != -1) {
      _bulkMunroUpdateList[index] = {..._bulkMunroUpdateList[index], ...munro};
    }
    notifyListeners();
  }
}

enum BulkMunroUpdateStatus { initial, loading, loaded, error }
