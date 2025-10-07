// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:two_eight_two/repos/repos.dart';

class FollowingService {
  static Future followUser(
    BuildContext context, {
    required String profileUserId,
    required String profileUserDisplayName,
    String? profileUserPictureURL,
  }) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    startCircularProgressOverlay(context);
    try {
      if (userState.currentUser == null) {
        stopCircularProgressOverlay(context);
        return;
      }

      FollowingRelationship followingRelationship = FollowingRelationship(
        sourceId: userState.currentUser?.uid ?? "",
        targetId: profileUserId,
        targetDisplayName: profileUserDisplayName,
        targetProfilePictureURL: profileUserPictureURL,
        targetSearchName: profileUserDisplayName.toLowerCase(),
        sourceDisplayName: userState.currentUser!.displayName!,
        sourceProfilePictureURL: userState.currentUser!.profilePictureURL,
      );
      // Create relationship
      await FollowingRelationshipsDatabase.create(context, followingRelationship: followingRelationship);

      // Update app state
      if (profileState.user == null) {
        profileState.setIsFollowing = true;
        stopCircularProgressOverlay(context);
        return;
      }
      AppUser tempUser = profileState.user!.copyWith(followersCount: (profileState.user?.followersCount ?? 0) + 1);
      profileState.setUser = tempUser;
      profileState.setIsFollowing = true;
      stopCircularProgressOverlay(context);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(message: "There was an issue following this user. Please try again.");
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: "There was an issue following this user. Please try again.");
    }
  }

  static Future unfollowUser(
    BuildContext context, {
    required String profileUserId,
  }) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    startCircularProgressOverlay(context);
    try {
      if (userState.currentUser == null) {
        stopCircularProgressOverlay(context);
        return;
      }

      // Create relationship
      await FollowingRelationshipsDatabase.delete(
        context,
        sourceId: userState.currentUser!.uid!,
        targetId: profileUserId,
      );

      // Update app state
      if (profileState.user != null) {
        AppUser tempUser = profileState.user!.copyWith(followersCount: profileState.user!.followersCount! - 1);
        profileState.setUser = tempUser;
        profileState.setIsFollowing = false;
      }

      stopCircularProgressOverlay(context);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(message: "There was an issue unfollowing this user. Please try again.");
      stopCircularProgressOverlay(context);
      showErrorDialog(context, message: "There was an issue unfollowing this user. Please try again.");
    }
  }

  static Future loadInitialFollowersAndFollowing(BuildContext context, {required String userId}) async {
    FollowersState followersState = Provider.of<FollowersState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    List<String> blockedUsers = userState.blockedUsers;

    try {
      followersState.setStatus = FollowersStatus.loading;
      followersState.setFollowers = await FollowingRelationshipsDatabase.getFollowersFromUid(
        context,
        targetId: userId,
        excludedUserIds: blockedUsers,
      );

      followersState.setFollowing = await FollowingRelationshipsDatabase.getFollowingFromUid(
        context,
        sourceId: userId,
        excludedUserIds: blockedUsers,
      );

      followersState.setStatus = FollowersStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      followersState.setError = Error(message: "There was an issue. Please try again.");
    }
  }

  static Future paginateFollowers(BuildContext context, {required String userId}) async {
    FollowersState followersState = Provider.of<FollowersState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    List<String> blockedUsers = userState.blockedUsers;

    try {
      followersState.setStatus = FollowersStatus.paginating;

      // Add followers from database
      followersState.addFollowers = await FollowingRelationshipsDatabase.getFollowersFromUid(
        context,
        targetId: userId,
        excludedUserIds: blockedUsers,
        offset: followersState.followers.length,
      );

      followersState.setStatus = FollowersStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      followersState.setError = Error(message: "There was an issue. Please try again.");
    }
  }

  static Future paginateFollowing(BuildContext context, {required String userId}) async {
    FollowersState followersState = Provider.of<FollowersState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    List<String> blockedUsers = userState.blockedUsers;

    try {
      followersState.setStatus = FollowersStatus.paginating;

      // Add followers from database
      followersState.addFollowing = await FollowingRelationshipsDatabase.getFollowingFromUid(
        context,
        sourceId: userId,
        excludedUserIds: blockedUsers,
        offset: followersState.following.length,
      );
      followersState.setStatus = FollowersStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      followersState.setError = Error(message: "There was an issue. Please try again.");
    }
  }
}
