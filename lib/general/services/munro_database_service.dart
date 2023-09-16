import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';

class MunroDatabaseService {
  static Future loadBasicMunroData(BuildContext context) async {
    List<Munro> munroList = [];
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context, listen: false);
    String dataString = await rootBundle.loadString('assets/munros.json');
    var data = jsonDecode(dataString);
    for (var munro in data) {
      munroList.add(Munro.fromJSON(munro));
    }

    munroNotifier.setMunroList = munroList;
  }
}
