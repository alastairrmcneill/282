import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
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
    final loggedInUser = Provider.of<AppUser?>(context);
    NavigationState navigationState = Provider.of<NavigationState>(context);
    if (profile == null) return const SizedBox();

    return ElevatedButton(
      onPressed: () async {
        if (loggedInUser == null) {
          navigationState.setNavigateToRoute = FeedTab.route;
          Navigator.of(context).pushNamed(AuthHomeScreen.route);
        } else {
          if (isFollowing) {
            await FollowingService.unfollowUser(
              context,
              profileUserId: profile!.id!,
            );
          } else {
            await FollowingService.followUser(
              context,
              targetUserId: profile!.id!,
            );
          }
        }
      },
      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
