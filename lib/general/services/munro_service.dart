import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/munro.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class MunroService {
  static Future<void> loadMunroData(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context, listen: false);

    // Load in munro data
    List<Munro> munroList = [];
    munroList = await MunroDatabaseService.loadBasicMunroData(context);

    if (userState.currentUser != null) {
      // Add personal munro data
      var dictMap = {
        for (var dict in userState.currentUser!.personalMunroData!) dict['id']: dict
      };

      // Iterate over the list of Munro objects and update them
      for (var munro in munroList) {
        var correspondingDict = dictMap[munro.id];
        if (correspondingDict != null) {
          munro.summited = correspondingDict[MunroFields.summited];
          munro.summitedDate =
              (correspondingDict[MunroFields.summitedDate] as Timestamp?)?.toDate();
          munro.saved = correspondingDict[MunroFields.saved];
        }
      }
    }
    munroNotifier.setMunroList = munroList;
  }

  static updateMunro(BuildContext context, {required Munro munro}) {
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context, listen: false);

    munroNotifier.updateMunro = munro;
  }

  static loadPersonalMunroData(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: false);
    print(userState.currentUser);
    if (userState.currentUser == null) return;
  }
}
