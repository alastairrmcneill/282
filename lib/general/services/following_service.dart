// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

class FollowingService {
  static Future isFollowingUser(
    BuildContext context, {
    required String profileUserId,
  }) async {
    try {
      FollowingState followingState = Provider.of<FollowingState>(context, listen: false);
      UserState userState = Provider.of<UserState>(context, listen: false);

      if (userState.currentUser == null) return;

      final querySnapshot = await FollowingRelationshipsDatabase.getRelationshipFromSourceAndTarget(
        context,
        sourceId: userState.currentUser?.uid ?? "",
        targetId: profileUserId,
      );

      followingState.setFollowingUser = querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error vailidating the relationship.");
    }
  }

  static Future followUser(
    BuildContext context, {
    required String profileUserId,
    required String profileUserDisplayName,
    String? profileUserPictureURL,
  }) async {
    startCircularProgressOverlay(context);
    UserState userState = Provider.of<UserState>(context, listen: false);

    if (userState.currentUser == null) {
      stopCircularProgressOverlay(context);
      return;
    }

    FollowingRelationship followingRelationship = FollowingRelationship(
      sourceId: userState.currentUser!.uid!,
      targetId: profileUserId,
      targetDisplayName: profileUserDisplayName,
      targetProfilePictureURL: profileUserPictureURL,
    );

    // Create relationship
    await FollowingRelationshipsDatabase.create(context, followingRelationship: followingRelationship);

    // Update app state
    FollowingState followingState = Provider.of<FollowingState>(context, listen: false);
    followingState.setFollowingUser = true;
    stopCircularProgressOverlay(context);
  }

  static Future unfollowUser(
    BuildContext context, {
    required String profileUserId,
  }) async {
    startCircularProgressOverlay(context);
    UserState userState = Provider.of<UserState>(context, listen: false);

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
    FollowingState followingState = Provider.of<FollowingState>(context, listen: false);
    followingState.setFollowingUser = false;
    stopCircularProgressOverlay(context);
  }

  static Future getMyFollowers(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);

    if (userState.currentUser == null) return;

    await FollowingRelationshipsDatabase.getFollowersFromUid(
      context,
      targetId: userState.currentUser!.uid!,
    );
  }

  static Future getMyFollowing(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);

    if (userState.currentUser == null) return;

    await FollowingRelationshipsDatabase.getFollowingFromUid(
      context,
      sourceId: userState.currentUser!.uid!,
    );
  }
}
