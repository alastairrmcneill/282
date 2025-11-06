import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class BlockedUserService {
  static Future blockUser(BuildContext context, {required String userId}) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    String? currentUserId = AuthService.currentUserId;

    if (currentUserId == null) return;

    BlockedUserRelationship blockedUserRelationship = BlockedUserRelationship(
      userId: currentUserId,
      blockedUserId: userId,
      dateTimeBlocked: DateTime.now(),
    );

    await BlockedUserDatabase.blockUser(context, blockedUserRelationship: blockedUserRelationship);

    userState.setBlockedUsers = [...userState.blockedUsers, userId];
  }

  static Future loadBlockedUsers(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    String? currentUserId = AuthService.currentUserId;

    if (currentUserId == null) return;

    // Load the blocked users list
    List<String> blockedUsers = await BlockedUserDatabase.getBlockedUsersForUid(
      context,
      userId: currentUserId,
    );

    // Update the state with the blocked users
    userState.setBlockedUsers = blockedUsers;
  }
}
