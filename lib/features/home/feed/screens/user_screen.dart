import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class UserScreen extends StatefulWidget {
  final AppUser user;
  const UserScreen({super.key, required this.user});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    checkFollowingStatus();
  }

// Usage example
  void checkFollowingStatus() async {
    await FollowingService.isFollowingUser(
      context,
      profileUserId: widget.user.uid!,
    ).whenComplete(() => setState(() => loading = false));
  }

  @override
  Widget build(BuildContext context) {
    FollowingState followingState = Provider.of<FollowingState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.displayName ?? ""),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: () async {
                if (followingState.followingUser) {
                  print('Unfollow');
                  await FollowingService.unfollowUser(context, profileUserId: widget.user.uid!);
                } else {
                  print("Follow");

                  await FollowingService.followUser(
                    context,
                    profileUserId: widget.user.uid!,
                    profileUserDisplayName: widget.user.displayName ?? "282 User",
                    profileUserPictureURL: widget.user.profilePictureURL,
                  );
                }
              },
              child: Text(followingState.followingUser ? 'Unfollow' : 'Follow'),
            ),
    );
  }
}
