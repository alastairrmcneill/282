import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/munro.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';

class MunroService {
  static updateMunro(BuildContext context, {required Munro munro}) {
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context, listen: false);

    munroNotifier.updateMunro = munro;
  }
}
