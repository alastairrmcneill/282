// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

class FollowersFollowingScreen extends StatelessWidget {
  const FollowersFollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowersState>(
      builder: (context, followersState, child) {
        switch (followersState.status) {
          case FollowersStatus.loading:
            return Scaffold(
              appBar: AppBar(),
              body: const LoadingWidget(),
            );
          case FollowersStatus.error:
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Uh oh, something went wrong. Please try again')),
            );
          case FollowersStatus.loaded:
            return _buildScreen(context, followersState);
          default:
            return Scaffold(appBar: AppBar());
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, FollowersState followersState) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(""),
          centerTitle: false,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Following"),
              Tab(text: "Followers"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            followersState.following.isEmpty
                ? const Center(child: Text('You are not following anyone yet.'))
                : ListView(
                    children: followersState.following
                        .map(
                          (followingRelationship) => ListTile(
                            leading: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[350],
                                image: followingRelationship.targetProfilePictureURL == null
                                    ? null
                                    : DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                          followingRelationship.targetProfilePictureURL!,
                                        ),
                                      ),
                              ),
                              child: followingRelationship.targetProfilePictureURL == null
                                  ? ClipOval(
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: Colors.grey[600],
                                        size: 28,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              followingRelationship.targetDisplayName,
                            ),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => UserScreen(userId: followingRelationship.targetId),
                              //   ),
                              // );
                            },
                          ),
                        )
                        .toList(),
                  ),
            followersState.followers.isEmpty
                ? const Center(child: Text('You are not followed by anyone yet.'))
                : ListView(
                    children: followersState.followers
                        .map(
                          (followingRelationship) => ListTile(
                            leading: Container(
                              width: 40.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[350],
                                image: followingRelationship.sourceProfilePictureURL == null
                                    ? null
                                    : DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                          followingRelationship.sourceProfilePictureURL!,
                                        ),
                                      ),
                              ),
                              child: followingRelationship.sourceProfilePictureURL == null
                                  ? ClipOval(
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: Colors.grey[600],
                                        size: 28,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(followingRelationship.sourceDisplayName),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => UserScreen(userId: followingRelationship.sourceId),
                              //   ),
                              // );
                            },
                          ),
                        )
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
