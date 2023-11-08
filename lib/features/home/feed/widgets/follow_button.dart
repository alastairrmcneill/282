import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/auth/screens/screens.dart';

import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class FollowingButton extends StatelessWidget {
  final bool isFollowing;
  final AppUser? user;
  const FollowingButton({
    super.key,
    required this.isFollowing,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<AppUser?>(context);
    NavigationState navigationState = Provider.of<NavigationState>(context);
    if (user == null) return const SizedBox();

    return ElevatedButton(
      onPressed: () async {
        if (loggedInUser == null) {
          navigationState.setNavigateToRoute = "/feed_tab";
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthHomeScreen()));
        } else {
          if (isFollowing) {
            await FollowingService.unfollowUser(
              context,
              profileUserId: user!.uid!,
            );
          } else {
            await FollowingService.followUser(
              context,
              profileUserId: user!.uid!,
              profileUserDisplayName: user!.displayName ?? "282 User",
              profileUserPictureURL: user!.profilePictureURL,
            );
          }
        }
      },
      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
