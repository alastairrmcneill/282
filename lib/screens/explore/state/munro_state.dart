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

  MunroStatus get status => _status;
  Error get error => _error;
  List<Munro> get munroList => _munroList;
  List<Munro> get filteredMunroList => _filteredMunroList;
  Munro? get selectedMunro => _selectedMunro;
  List<Munro> get createPostFilteredMunroList => _createPostFilteredMunroList;

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
    int munroIdInt = int.parse(munroId);
    _munroList[munroIdInt - 1].summited = summited ?? _munroList[munroIdInt - 1].summited;
    _munroList[munroIdInt - 1].summitedDate = summitedDate ?? _munroList[munroIdInt - 1].summitedDate;
    _munroList[munroIdInt - 1].saved = saved ?? _munroList[munroIdInt - 1].saved;

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

  reset() {
    _status = MunroStatus.initial;
    _error = Error();
    _munroList = [];
    _selectedMunro;
    _filteredMunroList = [];
    _filterString = '';
    _createPostFilteredMunroList = [];
    _createPostFilterString = '';
    _filter();
    _createPostFilter();
  }
}

enum MunroStatus { initial, loading, loaded, error }
