import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/services/services.dart';

class MunroService {
  static Future<void> loadMunroData(BuildContext context) async {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    try {
      munroState.setStatus = MunroStatus.loading;

      // Load in munro data
      List<Munro> munroList = [];

      munroList = await MunroDatabase.getMunroData(context);

      munroState.setMunroList = munroList;

      // Set status
      munroState.setStatus = MunroStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      munroState.setError = Error(
        code: error.toString(),
        message: "There was an issue loading you munro data",
      );
    }
  }
}
