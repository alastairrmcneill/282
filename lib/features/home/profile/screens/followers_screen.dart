import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/feed/screens/screens.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class FollowersFollowingScreen extends StatefulWidget {
  const FollowersFollowingScreen({super.key});

  @override
  State<FollowersFollowingScreen> createState() => _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen> {
  @override
  Widget build(BuildContext context) {
    FollowingState followingState = Provider.of<FollowingState>(context);
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
            ListView(
              children: followingState.myFollowing!
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserScreen(userId: followingRelationship.targetId),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
            ListView(
              children: followingState.myFollowers!
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserScreen(userId: followingRelationship.sourceId),
                          ),
                        );
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
