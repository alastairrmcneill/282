import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class UserService {
  static Future<List<AppUser>> searchUsers(
    BuildContext context, {
    required String searchTerm,
  }) async {
    UserRepository repo = context.read<UserRepository>();
    UserState userState = Provider.of<UserState>(context, listen: false);
    List<String> blockedUsers = userState.blockedUsers;
    try {
      List<AppUser> users = await repo.readUsersByName(
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
    final userState = context.read<UserState>();
    if (userState.currentUser == null) return;

    AppUser updatedUser = userState.currentUser!.copyWith(profileVisibility: newValue);
    userState.updateUser(appUser: updatedUser);
  }

  static Future updateProfile(BuildContext context, {required AppUser appUser, File? profilePicture}) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    UserState userState = context.read<UserState>();
    ProfileRepository profileRepo = context.read<ProfileRepository>();
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
      await userState.updateUser(appUser: appUser);

      // Update profile
      profileState.setProfile = await profileRepo.getProfileFromUserId(userId: appUser.uid!);
      stopCircularProgressOverlay(context);
      Navigator.pop(context);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: "There was an issue updating the profile.");
    }
  }
}
