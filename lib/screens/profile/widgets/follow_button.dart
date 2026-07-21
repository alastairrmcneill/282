import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

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

    void onPressed() {
      if (loggedInUser == null) {
        Navigator.of(context).pushNamed(
          AuthHomeScreen.route,
          arguments: const AuthHomeScreenArgs(gateSource: 'follow_button'),
        );
      } else {
        final profileState = context.read<ProfileState>();
        if (isFollowing) {
          currentUserFollowerState.unfollowUser(targetUserId: profile!.id!);
          profileState.adjustFollowersCount(-1);
        } else {
          currentUserFollowerState.followUser(targetUserId: profile!.id!);
          profileState.adjustFollowersCount(1);
        }
      }
    }

    if (isFollowing) {
      return SecondaryButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsRegular.userMinus, size: 16),
            const SizedBox(width: 6),
            const Text('Following'),
          ],
        ),
      );
    }

    return PrimaryButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIconsRegular.userPlus, size: 16),
          const SizedBox(width: 6),
          const Text('Follow'),
        ],
      ),
    );
  }
}
