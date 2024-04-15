import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class SavedListService {
  static Future createSavedList(BuildContext context) async {
    SavedListState savedListState = Provider.of<SavedListState>(context, listen: false);

    try {
      savedListState.setStatus = SavedListStatus.loading;

      // TODO: Decide how to create list
      // Build in widget and send through
      // Build in notifier and open notifier here

      savedListState.setStatus = SavedListStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      savedListState.setError = Error(
        message: "There was an issue creating your list. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future readUserSavedLists(BuildContext context) async {
    // Read the user's saved lists
    print("Reading user's saved lists");
    SavedListState savedListState = Provider.of<SavedListState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      savedListState.setStatus = SavedListStatus.loading;

      List<SavedList> savedLists = await SavedListDatabase.readFromUserUid(
        context,
        userUid: userState.currentUser?.uid ?? "",
      );

      savedListState.setSavedLists = savedLists;
      savedListState.setStatus = SavedListStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      savedListState.setError = Error(
        message: "There was an issue reading your saved lists. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future updateSavedListName(BuildContext context) async {
    // Update a saved list
  }

  static Future deleteSavedList(BuildContext context) async {
    // Delete a saved list
  }
}
