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
      profileState.setIsFollowing = await _isFollowingUser(
        context,
        currentUserId: userState.currentUser?.uid ?? "",
        profileUserId: userId,
      );

      profileState.setPosts = await PostService.getProfilePosts(context);

      // Set loading status?
      profileState.setStatus = ProfileStatus.loaded;
    } catch (error) {
      profileState.setError = Error(
        code: error.toString(),
        message: "There was an issue. Please try again.",
      );
    }
  }

  static Future<bool> _isFollowingUser(
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
    } catch (error) {
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
      await UserDatabase.update(context, appUser: appUser);

      // Update profile
      profileState.setUser = await UserDatabase.readUserFromUid(context, uid: appUser.uid!);
      stopCircularProgressOverlay(context);
      Navigator.pop(context);
    } catch (error) {
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: "There was an issue updating your account");
    }
  }
}
