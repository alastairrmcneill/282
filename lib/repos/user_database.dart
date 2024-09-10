// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class UserDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _userRef = _db.collection('users');

  // Create user
  static Future create(BuildContext context, {required AppUser appUser}) async {
    try {
      // see if this user already exists

      final DocumentReference userDocRef = _userRef.doc(appUser.uid);
      final DocumentSnapshot userDocSnapshot = await userDocRef.get();
      if (!userDocSnapshot.exists) {
        await userDocRef.set(appUser.toJSON());
      }
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error creating your account.");
    }
  }

  // Update user
  static Future update(BuildContext context, {required AppUser appUser}) async {
    try {
      DocumentReference ref = _userRef.doc(appUser.uid);

      await ref.update(appUser.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error updating your account.");
    }
  }

  // Delete user
  static Future deleteUserWithUID(BuildContext context, {required String uid}) async {
    try {
      DocumentReference ref = _userRef.doc(uid);

      await ref.delete();
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error deleting your account");
    }
  }

  // Read single user
  static Future<AppUser?> readUserFromUid(BuildContext context, {required String uid}) async {
    try {
      DocumentReference ref = _userRef.doc(uid);
      DocumentSnapshot documentSnapshot = await ref.get();

      Map<String, Object?> data = documentSnapshot.data() as Map<String, Object?>;

      AppUser appUser = AppUser.fromJSON(data);

      return appUser;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error fetching your account.");
      return null;
    }
  }

  // Read multiple users
  static Future<List<AppUser>> readUsersByName(
    BuildContext context, {
    required String searchTerm,
    required String? lastUserId,
  }) async {
    List<AppUser> searchResult = [];
    QuerySnapshot<Map<String, dynamic>> userSnap;

    try {
      if (lastUserId == null) {
        // Carry out first search

        userSnap = await _db
            .collection('users')
            .where(AppUserFields.profileVisibility, isEqualTo: Privacy.public)
            .orderBy(AppUserFields.searchName, descending: false)
            .startAt([searchTerm])
            .endAt(["$searchTerm\uf8ff"])
            .limit(20)
            .get();
      } else {
        // Carry out paginated search
        final lastUserDoc = await _db.collection('users').doc(lastUserId).get();

        if (!lastUserDoc.exists) return [];
        userSnap = await _db
            .collection('users')
            .where(AppUserFields.profileVisibility, isEqualTo: Privacy.public)
            .orderBy(AppUserFields.searchName, descending: false)
            .startAfterDocument(lastUserDoc)
            .endAt(["$searchTerm\uf8ff"])
            .limit(20)
            .get();
      }

      for (var doc in userSnap.docs) {
        searchResult.add(AppUser.fromJSON(doc.data()));
      }

      return searchResult;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.toString());
      return searchResult;
    }
  }

  static Future<List<AppUser>> readUsersFromUids(BuildContext context, {required List<String> uids}) async {
    List<AppUser> users = [];

    try {
      // Split UIDs into chunks of 10 (since Firestore 'in' query supports max 10 items)
      const int chunkSize = 10;
      List<List<String>> chunks = [];
      for (var i = 0; i < uids.length; i += chunkSize) {
        chunks.add(uids.sublist(i, i + chunkSize > uids.length ? uids.length : i + chunkSize));
      }

      // Perform queries in parallel
      List<Future<QuerySnapshot>> futures = chunks.map((chunk) {
        return _userRef.where(AppUserFields.uid, whereIn: chunk).get();
      }).toList();

      // Wait for all futures to complete
      List<QuerySnapshot> querySnapshots = await Future.wait(futures);

      // Collect all the documents from the query users
      for (QuerySnapshot snapshot in querySnapshots) {
        for (var doc in snapshot.docs) {
          users.add(AppUser.fromJSON(doc.data() as Map<String, dynamic>));
        }
      }

      return users;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.toString());
      return users;
    }
  }
}
