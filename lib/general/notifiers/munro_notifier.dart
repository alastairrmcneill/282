import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/munro.dart';

class MunroNotifier extends ChangeNotifier {
  List<Munro> _munroList = [];
  Munro? _selectedMunro;
  List<Munro> _filteredMunroList = [];
  String _filterString = '';

  List<Munro> get munroList => _munroList;
  List<Munro> get filteredMunroList => _filteredMunroList;
  Munro? get selectedMunro => _selectedMunro;

  set setMunroList(List<Munro> munroList) {
    _munroList = munroList;
    notifyListeners();
  }

  set setSelectedMunro(Munro? selectedMunro) {
    _selectedMunro = selectedMunro;
    notifyListeners();
  }

  updateMunro({
    required int munroId,
    bool? summited,
    DateTime? summitedDate,
    bool? saved,
  }) {
    _munroList[munroId - 1].summited = summited ?? _munroList[munroId - 1].summited;
    _munroList[munroId - 1].summitedDate =
        summitedDate ?? _munroList[munroId - 1].summitedDate;
    _munroList[munroId - 1].saved = saved ?? _munroList[munroId - 1].saved;

    notifyListeners();
  }

  set setFilterString(String filterString) {
    _filterString = filterString;
    _filter();
  }

  _filter() {
    List<Munro> runningList = [];
    if (_filterString != "") {
      runningList = _munroList
          .where(
            (munro) => munro.name.toLowerCase().contains(_filterString.toLowerCase()),
          )
          .toList();
    }
    _filteredMunroList = runningList;
    notifyListeners();
  }
}
