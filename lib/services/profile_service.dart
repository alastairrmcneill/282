// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class ProfileService {
  static Future loadUserFromUid(BuildContext context, {required String userId}) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      profileState.setStatus = ProfileStatus.loading;
      // Load user from database
      profileState.setProfile = await ProfileDatabase.getProfileFromUserId(userId: userId);

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
      final relationshipExists = await FollowingRelationshipsDatabase.relationshipExists(
        context,
        sourceId: currentUserId,
        targetId: profileUserId,
      );

      return relationshipExists;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      return false;
    }
  }

  static Future getProfileMunroCompletions(BuildContext context, {required String userId}) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    try {
      final munroCompletions = await MunroCompletionsDatabase.getUserMunroCompletions(
        context,
        userId: userId,
      );
      profileState.setMunroCompletions = munroCompletions;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(
        code: error.toString(),
        message: "There was an issue loading the munros. Please try again.",
      );
    }
  }
}
