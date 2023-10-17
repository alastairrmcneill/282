import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/munro.dart';

class MunroNotifier extends ChangeNotifier {
  List<Munro> _munroList = [];
  List<Munro> _filteredMunroList = [];
  String _filterString = '';

  List<Munro> get munroList => _munroList;
  List<Munro> get filteredMunroList => _filteredMunroList;

  set setMunroList(List<Munro> munroList) {
    _munroList = munroList;
    notifyListeners();
  }

  set updateMunro(Munro munro) {
    _munroList[munro.id - 1] = munro;

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
