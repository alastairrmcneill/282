// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class UserDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _userRef = _db.from('users');

  // Create user
  static Future create(BuildContext context, {required AppUser appUser}) async {
    try {
      // see if this user already exists
      final response = await _userRef.select().eq(AppUserFields.uid, appUser.uid ?? "").maybeSingle();

      if (response == null) {
        await _userRef.insert(appUser.toJSON());
      }
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error creating your account.");
    }
  }

  // Update user
  static Future update(BuildContext context, {required AppUser appUser}) async {
    try {
      await _userRef.update(appUser.toJSON()).eq(AppUserFields.uid, appUser.uid ?? "");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error updating your account.");
    }
  }

  // Delete user
  static Future deleteUserWithUID(BuildContext context, {required String uid}) async {
    try {
      await _userRef.delete().eq(AppUserFields.uid, uid);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error deleting your account");
    }
  }

  // Read single user
  static Future<AppUser?> readUserFromUid(BuildContext context, {required String uid}) async {
    try {
      final response = await _userRef.select().eq(AppUserFields.uid, uid).single();

      AppUser appUser = AppUser.fromJSON(response);

      return appUser;
    } catch (error, stackTrace) {
      FirebaseAuth.instance.signOut();
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error getting your account.");
      return null;
    }
  }

  // Read multiple users
  static Future<List<AppUser>> readUsersByName(
    BuildContext context, {
    required String searchTerm,
    required List<String> excludedAuthorIds,
    int offset = 0,
  }) async {
    List<AppUser> searchResult = [];
    int pageSize = 10;

    try {
      final response = await _userRef
          .select()
          .ilike(AppUserFields.searchName, '%$searchTerm%')
          .not(AppUserFields.uid, 'in', excludedAuthorIds)
          .eq(AppUserFields.profileVisibility, Privacy.public)
          .order(AppUserFields.searchName, ascending: true)
          .range(offset, offset + pageSize - 1);

      for (var doc in response) {
        searchResult.add(AppUser.fromJSON(doc));
      }

      return searchResult;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.toString());
      return searchResult;
    }
  }

  static Future<List<AppUser>> readUsersFromUids(BuildContext context, {required List<String> uids}) async {
    List<AppUser> users = [];
    List<Map<String, dynamic>> response = [];

    try {
      if (uids.isEmpty) {
        return users;
      }

      response = await _userRef.select().inFilter(AppUserFields.uid, uids);

      for (var doc in response) {
        users.add(AppUser.fromJSON(doc));
      }

      return users;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.toString());
      return users;
    }
  }
}
