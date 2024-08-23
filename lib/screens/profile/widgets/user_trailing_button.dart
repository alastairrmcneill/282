import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

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
    following = await ProfileService.isFollowingUser(
      context,
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
                      navigationState.setNavigateToRoute = HomeScreen.profileTabRoute;
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthHomeScreen()));
                    } else {
                      FollowingService.unfollowUser(
                        context,
                        profileUserId: widget.profileUserId,
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
                      navigationState.setNavigateToRoute = HomeScreen.profileTabRoute;
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthHomeScreen()));
                    } else {
                      FollowingService.followUser(
                        context,
                        profileUserId: widget.profileUserId,
                        profileUserDisplayName: widget.profileUserDisplayName,
                        profileUserPictureURL: widget.profileUserPictureURL,
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
