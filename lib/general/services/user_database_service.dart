// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

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
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error creating your account.");
    }
  }

  // Read current user
  static Future readCurrentUser(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    try {
      String? uid = AuthService.currentUserId;
      if (uid == null) return;
      DocumentReference ref = _userRef.doc(uid);
      DocumentSnapshot documentSnapshot = await ref.get();

      if (!documentSnapshot.exists) return;

      Map<String, Object?> data = documentSnapshot.data() as Map<String, Object?>;

      AppUser appUser = AppUser.fromJSON(data);

      userState.setCurrentUser = appUser;
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error fetching your account.");
    }
  }

  // Update user
  static Future update(BuildContext context, {required AppUser appUser}) async {
    try {
      DocumentReference ref = _userRef.doc(appUser.uid);

      await ref.update(appUser.toJSON());
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error updating your account.");
    }
  }

  // Delete user
  static Future deleteUserWithUID(BuildContext context, {required String uid}) async {
    try {
      DocumentReference ref = _userRef.doc(uid);

      await ref.delete();
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error deleting your account");
    }
  }

  static Future<AppUser?> readUserFromUid(BuildContext context, {required String uid}) async {
    try {
      DocumentReference ref = _userRef.doc(uid);
      DocumentSnapshot documentSnapshot = await ref.get();

      Map<String, Object?> data = documentSnapshot.data() as Map<String, Object?>;

      AppUser appUser = AppUser.fromJSON(data);

      return appUser;
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error fetching your account.");
      return null;
    }
  }
}
