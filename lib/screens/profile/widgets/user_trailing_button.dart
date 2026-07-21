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

    void onPressed() {
      if (userState.currentUser == null) {
        Navigator.of(context).pushNamed(
          AuthHomeScreen.route,
          arguments: const AuthHomeScreenArgs(gateSource: 'profile_tab'),
        );
      } else if (isFollowing) {
        currentUserFollowerState.unfollowUser(targetUserId: profileUserId);
      } else {
        currentUserFollowerState.followUser(targetUserId: profileUserId);
      }
    }

    final compactStyle = ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 14),
      ),
      minimumSize: WidgetStateProperty.all(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStateProperty.all(
        Theme.of(context).textTheme.labelMedium,
      ),
    );

    return SizedBox(
      width: 96,
      height: 32,
      child: isFollowing
          ? OutlinedButton(
              style: compactStyle,
              onPressed: onPressed,
              child: const Text("Following"),
            )
          : FilledButton(
              style: compactStyle,
              onPressed: onPressed,
              child: const Text("Follow"),
            ),
    );
  }
}
