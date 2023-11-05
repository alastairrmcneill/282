// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

class FollowingService {
  static Future followUser(
    BuildContext context, {
    required String profileUserId,
    required String profileUserDisplayName,
    String? profileUserPictureURL,
  }) async {
    startCircularProgressOverlay(context);
    UserState userState = Provider.of<UserState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);

    if (userState.currentUser == null) {
      stopCircularProgressOverlay(context);
      return;
    }

    FollowingRelationship followingRelationship = FollowingRelationship(
      sourceId: userState.currentUser!.uid!,
      targetId: profileUserId,
      targetDisplayName: profileUserDisplayName,
      targetProfilePictureURL: profileUserPictureURL,
      sourceDisplayName: userState.currentUser!.displayName!,
      sourceProfilePictureURL: userState.currentUser!.profilePictureURL,
    );
    // Create relationship
    await FollowingRelationshipsDatabase.create(context, followingRelationship: followingRelationship);

    // Update app state
    AppUser tempUser = profileState.user!.copyWith(followersCount: profileState.user!.followersCount! + 1);
    profileState.setUser = tempUser;
    profileState.setIsFollowing = true;
    stopCircularProgressOverlay(context);
  }

  static Future unfollowUser(
    BuildContext context, {
    required String profileUserId,
  }) async {
    startCircularProgressOverlay(context);
    UserState userState = Provider.of<UserState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);

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
    AppUser tempUser = profileState.user!.copyWith(followersCount: profileState.user!.followersCount! - 1);
    profileState.setUser = tempUser;
    profileState.setIsFollowing = false;

    stopCircularProgressOverlay(context);
  }

  static Future getFollowersAndFollowing(BuildContext context, {required String userId}) async {
    FollowersState followersState = Provider.of<FollowersState>(context, listen: false);

    followersState.setStatus = FollowersStatus.loading;

    followersState.setFollowers = await FollowingRelationshipsDatabase.getFollowersFromUid(
      context,
      targetId: userId,
    );

    followersState.setFollowing = await FollowingRelationshipsDatabase.getFollowingFromUid(
      context,
      sourceId: userId,
    );

    followersState.setStatus = FollowersStatus.loaded;
  }
}
