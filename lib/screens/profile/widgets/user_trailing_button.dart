import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class UserTrailingButton extends StatefulWidget {
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
  State<UserTrailingButton> createState() => _UserTrailingButtonState();
}

class _UserTrailingButtonState extends State<UserTrailingButton> {
  bool following = true;
  bool isCurrentUser = true;

  @override
  void initState() {
    super.initState();
    loadData(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future loadData(BuildContext context) async {
    AppUser? user = Provider.of<AppUser?>(context, listen: false);
    ProfileState profileState = context.read<ProfileState>();
    following = await profileState.isFollowingUser(
      currentUserId: user?.uid ?? "",
      profileUserId: widget.profileUserId,
    );

    isCurrentUser = user?.uid == widget.profileUserId;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context, listen: false);
    final followersState = context.read<FollowersState>();
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    return isCurrentUser
        ? const SizedBox()
        : following
            ? SizedBox(
                width: 100,
                child: OutlinedButton(
                  onPressed: () async {
                    // Check if logged in or not
                    if (user == null) {
                      navigationState.setNavigateToRoute = ProfileTab.route;
                      Navigator.of(context).pushNamed(AuthHomeScreen.route);
                    } else {
                      followersState.unfollowUser(
                        targetUserId: widget.profileUserId,
                      );
                      setState(() {
                        following = false;
                      });
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
                    if (user == null) {
                      navigationState.setNavigateToRoute = ProfileTab.route;
                      Navigator.of(context).pushNamed(AuthHomeScreen.route);
                    } else {
                      followersState.followUser(
                        targetUserId: widget.profileUserId,
                      );
                      setState(() {
                        following = true;
                      });
                    }
                  },
                  child: const Text("Follow"),
                ),
              );
  }
}
