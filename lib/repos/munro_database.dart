import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _munrosRef = _db.from('vu_munros');

  static Future<List<Munro>> getMunroData(BuildContext context) async {
    List<Munro> munroList = [];
    try {
      final response = await _munrosRef.select();
      munroList = response.map((item) => Munro.fromJSON(item)).toList();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error fetching munro data.");
    }

    return munroList;
  }
}
