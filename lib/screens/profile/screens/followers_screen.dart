// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/profile/screens/profile_screen.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FollowersFollowingScreen extends StatefulWidget {
  const FollowersFollowingScreen({super.key});

  @override
  State<FollowersFollowingScreen> createState() => _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen> {
  late ScrollController _followersScrollController;
  late ScrollController _followingScrollController;
  @override
  void initState() {
    FollowersState followersState = Provider.of<FollowersState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);

    _followersScrollController = ScrollController();
    _followersScrollController.addListener(() {
      if (_followersScrollController.offset >= _followersScrollController.position.maxScrollExtent &&
          !_followersScrollController.position.outOfRange &&
          followersState.status != FollowersStatus.paginating) {
        FollowingService.paginateFollowers(context, userId: profileState.user!.uid!);
      }
    });

    _followingScrollController = ScrollController();
    _followingScrollController.addListener(() {
      if (_followingScrollController.offset >= _followingScrollController.position.maxScrollExtent &&
          !_followingScrollController.position.outOfRange &&
          followersState.status != FollowersStatus.paginating) {
        FollowingService.paginateFollowing(context, userId: profileState.user!.uid!);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _followersScrollController.dispose();
    _followingScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowersState>(
      builder: (context, followersState, child) {
        switch (followersState.status) {
          case FollowersStatus.loading:
            return _buildLoadingScreen(followersState);
          case FollowersStatus.error:
            return Scaffold(
              appBar: AppBar(),
              body: CenterText(text: followersState.error.message),
            );
          default:
            return _buildScreen(
              context,
              followersState: followersState,
              followersScrollController: _followersScrollController,
              followingScrollController: _followingScrollController,
            );
        }
      },
    );
  }

  Widget _buildLoadingScreen(FollowersState followersState) {
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: () async {
          followersState.navigateBack();
          return true;
        },
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
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 30,
                itemBuilder: (context, index) => const ShimmerListTile(),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 30,
                itemBuilder: (context, index) => const ShimmerListTile(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(
    BuildContext context, {
    required FollowersState followersState,
    required ScrollController followersScrollController,
    required ScrollController followingScrollController,
  }) {
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: () async {
          followersState.navigateBack();
          return true;
        },
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
                  ? const Padding(
                      padding: EdgeInsets.all(15),
                      child: CenterText(text: "Not following anyone."),
                    )
                  : ListView(
                      controller: followingScrollController,
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
                                ProfileService.loadUserFromUid(context, userId: followingRelationship.targetId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              },
                            ),
                          )
                          .toList(),
                    ),
              followersState.followers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(15),
                      child: CenterText(text: "No followers."),
                    )
                  : ListView(
                      controller: followersScrollController,
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
                                ProfileService.loadUserFromUid(context, userId: followingRelationship.sourceId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
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
      ),
    );
  }
}
