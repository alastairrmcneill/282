import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class MunroState extends ChangeNotifier {
  MunroStatus _status = MunroStatus.initial;
  Error _error = Error();
  List<Munro> _munroList = [];
  Munro? _selectedMunro;
  List<Munro> _filteredMunroList = [];
  String _filterString = '';
  List<Munro> _createPostFilteredMunroList = [];
  String _createPostFilterString = '';
  List<Munro> _bulkMunroUpdateList = [];
  String _bulkMunroUpdateFilterString = '';

  MunroStatus get status => _status;
  Error get error => _error;
  List<Munro> get munroList => _munroList;
  List<Munro> get filteredMunroList => _filteredMunroList;
  Munro? get selectedMunro => _selectedMunro;
  List<Munro> get createPostFilteredMunroList => _createPostFilteredMunroList;
  List<Munro> get bulkMunroUpdateList => _bulkMunroUpdateList;

  set setStatus(MunroStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = MunroStatus.error;
    _error = error;
    notifyListeners();
  }

  set setMunroList(List<Munro> munroList) {
    _munroList = munroList;
    notifyListeners();
  }

  set setSelectedMunro(Munro? selectedMunro) {
    _selectedMunro = selectedMunro;
    notifyListeners();
  }

  updateMunro({
    required String munroId,
    bool? summited,
    DateTime? summitedDate,
    bool? saved,
  }) {
    int munroIndex = _munroList.indexWhere((munro) => munro.id == munroId);
    if (munroIndex == -1) return;
    _munroList[munroIndex].summited = summited ?? _munroList[munroIndex].summited;
    _munroList[munroIndex].summitedDate = summitedDate ?? _munroList[munroIndex].summitedDate;
    _munroList[munroIndex].saved = saved ?? _munroList[munroIndex].saved;

    if (summitedDate != null) {
      if (_munroList[munroIndex].summitedDates == null) {
        _munroList[munroIndex].summitedDates = [summitedDate];
      }
      _munroList[munroIndex].summitedDates!.add(summitedDate);
    }

    notifyListeners();
  }

  void removeMunroCompletion({
    required String munroId,
    required DateTime dateTime,
  }) {
    int munroIndex = _munroList.indexWhere((munro) => munro.id == munroId);
    if (munroIndex == -1) return;
    _munroList[munroIndex].summitedDates!.remove(dateTime);
    _munroList[munroIndex].summited = _munroList[munroIndex].summitedDates!.isNotEmpty;
    notifyListeners();
  }

  set setFilterString(String filterString) {
    _filterString = filterString;
    _filter();
  }

  _filter() {
    List<Munro> runningList = [];
    if (_filterString != "") {
      runningList = _munroList.where(
        (munro) {
          if (munro.name.toLowerCase().contains(_filterString.toLowerCase())) return true;
          if (munro.area.toLowerCase().contains(_filterString.toLowerCase())) return true;
          if (munro.extra != null) {
            if (munro.extra!.toLowerCase().contains(_filterString.toLowerCase())) return true;
          }
          return false;
        },
      ).toList();
    }
    _filteredMunroList = runningList;
    notifyListeners();
  }

  set setCreatePostFilterString(String filterString) {
    _createPostFilterString = filterString;
    _createPostFilter();
  }

  _createPostFilter() {
    List<Munro> runningList = _munroList;
    if (_createPostFilterString != "") {
      runningList = _munroList.where(
        (munro) {
          if (munro.name.toLowerCase().contains(_createPostFilterString.toLowerCase())) return true;
          if (munro.area.toLowerCase().contains(_createPostFilterString.toLowerCase())) return true;
          if (munro.extra != null) {
            if (munro.extra!.toLowerCase().contains(_createPostFilterString.toLowerCase())) return true;
          }
          return false;
        },
      ).toList();
    }
    _createPostFilteredMunroList = runningList;
    notifyListeners();
  }

  set setBulkMunroUpdateFilterString(String filterString) {
    _bulkMunroUpdateFilterString = filterString;
    _bulkMunroUpdateFilter();
  }

  _bulkMunroUpdateFilter() {
    List<Munro> runningList = _munroList;
    if (_bulkMunroUpdateFilterString != "") {
      runningList = _munroList.where(
        (munro) {
          if (munro.name.toLowerCase().contains(_bulkMunroUpdateFilterString.toLowerCase())) return true;
          if (munro.area.toLowerCase().contains(_bulkMunroUpdateFilterString.toLowerCase())) return true;
          if (munro.extra != null) {
            if (munro.extra!.toLowerCase().contains(_bulkMunroUpdateFilterString.toLowerCase())) return true;
          }
          return false;
        },
      ).toList();
    }
    _bulkMunroUpdateList = runningList;
    notifyListeners();
  }

  reset() {
    _status = MunroStatus.initial;
    _error = Error();
    _munroList = [];
    _selectedMunro;
    _filteredMunroList = [];
    _filterString = '';
    _createPostFilteredMunroList = [];
    _createPostFilterString = '';
    _bulkMunroUpdateList = [];
    _bulkMunroUpdateFilterString = '';
    _filter();
    _createPostFilter();
    _bulkMunroUpdateFilter();
  }
}

enum MunroStatus { initial, loading, loaded, error }
