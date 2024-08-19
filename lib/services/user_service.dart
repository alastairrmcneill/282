import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class UserService {
  static Future createUser(BuildContext context, {required AppUser appUser}) async {
    try {
      await UserDatabase.create(context, appUser: appUser);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
    }
  }

  static Future updateUser(BuildContext context, {required AppUser appUser}) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    try {
      await UserDatabase.update(context, appUser: appUser);
      userState.setCurrentUser = appUser;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
    }
  }

  static Future readCurrentUser(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    try {
      userState.setStatus = UserStatus.loading;

      String? uid = AuthService.currentUserId;
      if (uid == null) {
        userState.setStatus = UserStatus.loaded;
        return;
      }

      AppUser? appUser = await UserDatabase.readUserFromUid(context, uid: uid);

      userState.setCurrentUser = appUser;

      userState.setStatus = UserStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      userState.setError = Error(code: error.toString(), message: "There was an error fetching the account.");
    }
  }

  static Future deleteUser(BuildContext context, {required AppUser appUser}) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    try {
      await UserDatabase.deleteUserWithUID(context, uid: appUser.uid!);
      userState.setCurrentUser = null;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      userState.setError = Error(code: error.toString(), message: "There was an error deleting the account.");
    }
  }

  static Future<List<AppUser>> searchUsers(
    BuildContext context, {
    required String searchTerm,
    required String? lastUserId,
  }) async {
    try {
      List<AppUser> users = await UserDatabase.readUsersByName(
        context,
        searchTerm: searchTerm,
        lastUserId: lastUserId,
      );

      return users;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      return [];
    }
  }

  static Future updateProfileVisibility(BuildContext context, String newValue) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    AppUser? currentUser = userState.currentUser;
    if (currentUser == null) return;

    AppUser updatedUser = currentUser.copyWith(profileVisibility: newValue);
    UserService.updateUser(context, appUser: updatedUser);
  }
}
