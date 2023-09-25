import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/munro.dart';

class MunroNotifier extends ChangeNotifier {
  List<Munro> _munroList = [];

  List<Munro> get munroList => _munroList;

  set setMunroList(List<Munro> munroList) {
    _munroList = munroList;
    notifyListeners();
  }

  set updateMunro(Munro munro) {
    _munroList[munro.id - 1] = munro;

    notifyListeners();
  }
}
