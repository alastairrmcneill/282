// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ProfileService {
  static Future loadUserFromUid(BuildContext context, {required String userId}) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      profileState.setStatus = ProfileStatus.loading;
      // Load user from database
      profileState.setUser = await UserDatabase.readUserFromUid(context, uid: userId);

      // Check if this is current user
      profileState.setIsCurrentUser = userState.currentUser?.uid == userId;

      // Check if current user is following this user
      profileState.setIsFollowing = await isFollowingUser(
        context,
        currentUserId: userState.currentUser?.uid ?? "",
        profileUserId: userId,
      );

      profileState.setPosts = await PostService.getProfilePosts(context);

      // Load profile pictures
      MunroPictureService.getProfilePictures(context, profileId: userId);

      // Set loading status?
      profileState.setStatus = ProfileStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(
        code: error.toString(),
        message: "There was an issue loading the profile. Please try again.",
      );
    }
  }

  static Future<bool> isFollowingUser(
    BuildContext context, {
    required String currentUserId,
    required String profileUserId,
  }) async {
    try {
      final querySnapshot = await FollowingRelationshipsDatabase.getRelationshipFromSourceAndTarget(
        context,
        sourceId: currentUserId,
        targetId: profileUserId,
      );

      return querySnapshot.docs.isNotEmpty;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      return false;
    }
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

      // TODO update relationships

      // Update Auth
      await AuthService.updateAuthUser(context, appUser: appUser);

      // Update user database
      await UserService.updateUser(context, appUser: appUser);

      // Update profile
      profileState.setUser = await UserDatabase.readUserFromUid(context, uid: appUser.uid!);
      stopCircularProgressOverlay(context);
      Navigator.pop(context);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: "There was an issue updating the profile.");
    }
  }
}
