import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SavedListDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _savedListsRef = _db.from('saved_lists');
  static final SupabaseQueryBuilder _savedListsViewRef = _db.from('vu_saved_lists');

  static Future<SavedList> create(BuildContext context, {required SavedList savedList}) async {
    try {
      Map<String, Object?> response = await _savedListsRef.insert(savedList.toJSON()).select().single();
      SavedList newSavedList = SavedList.fromJSON(response);
      return newSavedList;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error creating your saved list.");
      return savedList;
    }
  }

  static Future<SavedList?> readFromUid(BuildContext context, {required String uid}) async {
    try {
      Map<String, Object?> response = await _savedListsViewRef.select().eq('uid', uid).single();

      SavedList savedList = SavedList.fromJSON(response);

      return savedList;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error reading your saved lists.");
      return null;
    }
  }

  static Future<List<SavedList>> readFromUserUid(BuildContext context, {required String userUid}) async {
    List<Map<String, Object?>> response = [];
    List<SavedList> savedLists = [];
    try {
      response = await _savedListsViewRef
          .select()
          .eq(SavedListFields.userId, userUid)
          .order(SavedListFields.dateTimeCreated, ascending: false);

      for (var doc in response) {
        SavedList savedList = SavedList.fromJSON(doc);
        savedLists.add(savedList);
      }

      return savedLists;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error reading your saved lists.");
      return [];
    }
  }

  static Future update(BuildContext context, {required SavedList savedList}) async {
    try {
      await _savedListsRef.update(savedList.toJSON()).eq(SavedListFields.uid, savedList.uid ?? "");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error updating your saved list.");
    }
  }

  static Future deleteFromUid(BuildContext context, {required String uid}) async {
    try {
      await _savedListsRef.delete().eq(SavedListFields.uid, uid);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error deleting your saved list.");
    }
  }
}
