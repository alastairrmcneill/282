import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class UserScreen extends StatefulWidget {
  AppUser? user;
  final String? userId;
  UserScreen({super.key, this.user, this.userId});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
    checkFollowingStatus();
  }

  Future loadData() async {
    widget.user ??= await UserDatabase.readUserFromUid(context, uid: widget.userId!);
    await checkFollowingStatus();
    setState(() {
      loading = false;
    });
  }

// Usage example
  Future<void> checkFollowingStatus() async {
    if (widget.user?.uid == null) return;
    await FollowingService.isFollowingUser(
      context,
      profileUserId: widget.user!.uid!,
    ).whenComplete(() => setState(() => loading = false));
  }

  @override
  Widget build(BuildContext context) {
    FollowingState followingState = Provider.of<FollowingState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user?.displayName ?? ""),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[350],
                        image: widget.user?.profilePictureURL == null
                            ? null
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                  widget.user!.profilePictureURL!,
                                ),
                              ),
                      ),
                      child: widget.user?.profilePictureURL == null
                          ? ClipOval(
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.grey[600],
                                size: 70,
                              ),
                            )
                          : null,
                    ),
                    Text(widget.user?.displayName ?? "282 User"),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (followingState.followingUser) {
                      await FollowingService.unfollowUser(context, profileUserId: widget.user!.uid!);
                    } else {
                      await FollowingService.followUser(
                        context,
                        profileUserId: widget.user!.uid!,
                        profileUserDisplayName: widget.user!.displayName ?? "282 User",
                        profileUserPictureURL: widget.user!.profilePictureURL,
                      );
                    }
                  },
                  child: Text(followingState.followingUser ? 'Unfollow' : 'Follow'),
                ),
              ],
            ),
    );
  }
}
