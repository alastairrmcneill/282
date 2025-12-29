import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class UserTrailingButton extends StatelessWidget {
  final String profileUserId;
  final String profileUserDisplayName;
  final String profileUserPictureURL;
  const UserTrailingButton({
    super.key,
    required this.profileUserId,
    required this.profileUserDisplayName,
    required this.profileUserPictureURL,
  });

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserState>();
    final currentUserFollowerState = context.watch<CurrentUserFollowerState>();

    if (userState.currentUser?.uid == profileUserId) return const SizedBox();

    final isFollowing = currentUserFollowerState.isFollowing(profileUserId);

    return isFollowing
        ? SizedBox(
            width: 100,
            child: OutlinedButton(
              onPressed: () async {
                // Check if logged in or not
                if (userState.currentUser == null) {
                  Navigator.of(context).pushNamed(AuthHomeScreen.route);
                } else {
                  currentUserFollowerState.unfollowUser(
                    targetUserId: profileUserId,
                  );
                }
              },
              child: const Text("Unfollow"),
            ),
          )
        : SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () async {
                // Check if logged in or not
                if (userState.currentUser == null) {
                  Navigator.of(context).pushNamed(AuthHomeScreen.route);
                } else {
                  currentUserFollowerState.followUser(
                    targetUserId: profileUserId,
                  );
                }
              },
              child: const Text("Follow"),
            ),
          );
  }
}
