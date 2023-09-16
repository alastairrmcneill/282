import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:two_eight_two/general/models/models.dart';

class MunroDatabaseService {
  static loadBasicMunroData() async {
    List<Munro> munroList = [];
    String dataString = await rootBundle.loadString('assets/munros.json');
    var data = jsonDecode(dataString);
    for (var munro in data) {
      munroList.add(Munro.fromJSON(munro));
    }
    for (var munro in munroList) {
      print(munro.toJSON());
    }
  }
}
