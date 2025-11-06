import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/profile_database.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

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
  }) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    List<String> blockedUsers = userState.blockedUsers;

    try {
      List<AppUser> users = await UserDatabase.readUsersByName(
        context,
        searchTerm: searchTerm,
        excludedAuthorIds: blockedUsers,
        offset: 0,
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

  static Future updateProfile(BuildContext context, {required AppUser appUser, File? profilePicture}) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);

    try {
      startCircularProgressOverlay(context);
      // Upload new profile picture
      String? photoURL;
      if (profilePicture != null) {
        photoURL = await StorageService.uploadProfilePicture(profilePicture);
        appUser.profilePictureURL = photoURL;
      }

      // Update Auth
      await AuthService.updateAuthUser(context, appUser: appUser);

      // Update user database
      await UserService.updateUser(context, appUser: appUser);

      // Update profile
      profileState.setProfile = await ProfileDatabase.getProfileFromUserId(userId: appUser.uid!);
      stopCircularProgressOverlay(context);
      Navigator.pop(context);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: "There was an issue updating the profile.");
    }
  }
}
