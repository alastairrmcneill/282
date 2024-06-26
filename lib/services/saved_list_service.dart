import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/models/saved_list_model.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:uuid/uuid.dart';

class SavedListService {
  static Future createSavedList(BuildContext context, {required String name}) async {
    SavedListState savedListState = Provider.of<SavedListState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      savedListState.setStatus = SavedListStatus.loading;
      if (userState.currentUser == null) {
        savedListState.setError = Error(
          message: "You must be signed in to create a list",
          code: "user-not-signed-in",
        );
        return;
      }

      SavedList savedList = SavedList(
        uid: const Uuid().v4(),
        name: name,
        userId: userState.currentUser?.uid ?? "",
        munroIds: [],
      );

      await SavedListDatabase.create(context, savedList: savedList);

      savedListState.addSavedList(savedList);
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

  static Future updateSavedListName(BuildContext context, {required SavedList savedList}) async {
    // Update a saved list
    SavedListState savedListState = Provider.of<SavedListState>(context, listen: false);

    try {
      await SavedListDatabase.update(context, savedList: savedList);

      savedListState.updateSavedList(savedList);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      savedListState.setError = Error(
        message: "There was an issue updating your list. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future deleteSavedList(BuildContext context, {required SavedList savedList}) async {
    SavedListState savedListState = Provider.of<SavedListState>(context, listen: false);

    try {
      savedListState.removeSavedList(savedList);

      SavedListDatabase.deleteFromUid(context, uid: savedList.uid ?? "");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      savedListState.setError = Error(message: "There was an issue deleting your post. Please try again.");
    }
  }

  static Future addMunroToSavedList(
    BuildContext context, {
    required SavedList savedList,
    required String munroId,
  }) async {
    SavedListState savedListState = Provider.of<SavedListState>(context, listen: false);
    print("Adding Munro to saved list");
    try {
      if (savedList.munroIds.contains(munroId)) return;

      savedList.munroIds.add(munroId);
      savedListState.updateSavedList(savedList);

      await SavedListDatabase.update(context, savedList: savedList);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      savedListState.setError = Error(
        message: "There was an issue saving your Munro. Please try again",
        code: error.toString(),
      );
    }
  }

  static Future removeMunroFromSavedList(
    BuildContext context, {
    required SavedList savedList,
    required String munroId,
  }) async {
    SavedListState savedListState = Provider.of<SavedListState>(context, listen: false);
    print("Removing Munro from saved list");
    try {
      if (!savedList.munroIds.contains(munroId)) return;

      savedList.munroIds.remove(munroId);
      savedListState.updateSavedList(savedList);

      await SavedListDatabase.update(context, savedList: savedList);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      savedListState.setError = Error(
        message: "There was an issue removing your Munro. Please try again",
        code: error.toString(),
      );
    }
  }
}
