import 'package:flutter/material.dart';

import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/services/services.dart';

class FollowingButton extends StatelessWidget {
  final bool isFollowing;
  final AppUser user;
  const FollowingButton({
    super.key,
    required this.isFollowing,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (isFollowing) {
          await FollowingService.unfollowUser(
            context,
            profileUserId: user.uid!,
          );
        } else {
          await FollowingService.followUser(
            context,
            profileUserId: user.uid!,
            profileUserDisplayName: user.displayName ?? "282 User",
            profileUserPictureURL: user.profilePictureURL,
          );
        }
      },
      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
