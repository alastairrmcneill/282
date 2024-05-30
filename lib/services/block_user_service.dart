import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class BlockUserService {
  static Future blockUser(BuildContext context, {required String userId}) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    AppUser? user = userState.currentUser;
    if (user == null) return;

    // Add the user to the block list
    List<String> blockedUsers = user.blockedUsers ?? [];
    blockedUsers.add(userId);

    // Update the user's blocked users list
    AppUser newUser = user.copyWith(blockedUsers: blockedUsers);

    // Update the user in the database
    await UserService.updateUser(context, appUser: newUser);
  }
}
