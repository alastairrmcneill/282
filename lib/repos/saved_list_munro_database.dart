import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SavedListMunroDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _savedListMunrosRef = _db.from('saved_list_munros');

  static Future create(BuildContext context, {required SavedListMunro savedListMunro}) async {
    try {
      await _savedListMunrosRef.insert(savedListMunro.toJSON());
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error saving to your saved list.");
    }
  }

  static Future delete(BuildContext context, {required String savedListId, required int munroId}) async {
    try {
      await _savedListMunrosRef
          .delete()
          .eq(SavedListMunroFields.savedListId, savedListId)
          .eq(SavedListMunroFields.munroId, munroId);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error removing from your saved list.");
    }
  }
}
