import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class SavedListState extends ChangeNotifier {
  SavedListStatus _status = SavedListStatus.initial;
  Error _error = Error();
  List<SavedList> _savedLists = [];

  SavedListStatus get status => _status;
  Error get error => _error;
  List<SavedList> get savedLists => _savedLists;

  set setStatus(SavedListStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = SavedListStatus.error;
    _error = error;
    notifyListeners();
  }

  set setSavedLists(List<SavedList> savedLists) {
    _savedLists = savedLists;
    notifyListeners();
  }

  void removeSavedList(SavedList savedList) {
    if (_savedLists.contains(savedList)) {
      _savedLists.remove(savedList);
      notifyListeners();
    }
  }
}

enum SavedListStatus { initial, loading, loaded, error }
