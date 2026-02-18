import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class FollowingButton extends StatelessWidget {
  final bool isFollowing;
  final Profile? profile;
  const FollowingButton({
    super.key,
    required this.isFollowing,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final loggedInUser = context.read<AuthState>().currentUserId;
    final CurrentUserFollowerState currentUserFollowerState = context.watch<CurrentUserFollowerState>();
    if (profile == null) return const SizedBox();

    return ElevatedButton(
      onPressed: () async {
        if (loggedInUser == null) {
          Navigator.of(context).pushNamed(AuthHomeScreen.route);
        } else {
          if (isFollowing) {
            await currentUserFollowerState.unfollowUser(
              targetUserId: profile!.id!,
            );
          } else {
            await currentUserFollowerState.followUser(
              targetUserId: profile!.id!,
            );
          }
        }
      },
      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
