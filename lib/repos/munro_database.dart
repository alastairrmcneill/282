import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_eight_two/models/models.dart';

class MunroDatabase {
  static Future<List<Munro>> loadBasicMunroData(BuildContext context) async {
    List<Munro> munroList = [];
    String dataString = await rootBundle.loadString('assets/munros.json');
    var data = jsonDecode(dataString);
    for (var munro in data) {
      munroList.add(Munro.fromJSON(munro));
    }

    return munroList;
    // Check if user logged in
  }
}
