import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SavedListDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _savedListsRef = _db.collection('savedLists');

  static Future create(BuildContext context, {required SavedList savedList}) async {
    try {
      DocumentReference ref = _savedListsRef.doc(savedList.uid);

      SavedList newSavedList = savedList.copy(uid: ref.id);

      await ref.set(newSavedList.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error creating your saved list.");
    }
  }

  static Future<SavedList?> readFromUid(BuildContext context, {required String uid}) async {
    try {
      DocumentReference ref = _savedListsRef.doc(uid);
      DocumentSnapshot documentSnapshot = await ref.get();

      AnalyticsService.logDatabaseRead(
        method: "SavedListDatabase.readFromUid",
        collection: "savedLists",
        documentCount: 1,
        userId: null,
        documentId: uid,
      );

      Map<String, Object?> data = documentSnapshot.data() as Map<String, Object?>;

      SavedList savedList = SavedList.fromJSON(data);

      return savedList;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error reading your saved lists.");
      return null;
    }
  }

  static Future<List<SavedList>> readFromUserUid(BuildContext context, {required String userUid}) async {
    List<SavedList> savedLists = [];
    try {
      QuerySnapshot querySnapshot = await _savedListsRef.where(SavedListFields.userId, isEqualTo: userUid).get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        SavedList savedList = SavedList.fromJSON(doc.data() as Map<String, Object?>);
        savedLists.add(savedList);
      }

      AnalyticsService.logDatabaseRead(
        method: "SavedListDatabase.readFromUserUid",
        collection: "savedLists",
        documentCount: savedLists.length,
        userId: userUid,
        documentId: null,
      );

      return savedLists;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error reading your saved lists.");
      return [];
    }
  }

  static Future update(BuildContext context, {required SavedList savedList}) async {
    try {
      DocumentReference ref = _savedListsRef.doc(savedList.uid);

      await ref.update(savedList.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error updating your saved list.");
    }
  }

  static Future deleteFromUid(BuildContext context, {required String uid}) async {
    try {
      DocumentReference ref = _savedListsRef.doc(uid);

      await ref.delete();
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error deleting your saved list.");
    }
  }
}
