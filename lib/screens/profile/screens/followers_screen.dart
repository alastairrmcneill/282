// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/profile/screens/profile_screen.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FollowersFollowingScreen extends StatefulWidget {
  static const String route = '/profile/followers';
  const FollowersFollowingScreen({super.key});

  @override
  State<FollowersFollowingScreen> createState() => _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _followersScrollController;
  late ScrollController _followingScrollController;

  @override
  void initState() {
    super.initState();

    final followersState = Provider.of<FollowersState>(context, listen: false);
    final profileState = Provider.of<ProfileState>(context, listen: false);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _logTabAnalytics(_tabController.index);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logTabAnalytics(_tabController.index);
    });

    _followersScrollController = ScrollController();
    _followersScrollController.addListener(() {
      if (_followersScrollController.offset >= _followersScrollController.position.maxScrollExtent &&
          !_followersScrollController.position.outOfRange &&
          followersState.status != FollowersStatus.paginating) {
        followersState.paginateFollowers(userId: profileState.profile!.id!);
      }
    });

    _followingScrollController = ScrollController();
    _followingScrollController.addListener(() {
      if (_followingScrollController.offset >= _followingScrollController.position.maxScrollExtent &&
          !_followingScrollController.position.outOfRange &&
          followersState.status != FollowersStatus.paginating) {
        followersState.paginateFollowing(userId: profileState.profile!.id!);
      }
    });
  }

  void _logTabAnalytics(int index) {
    final screen = index == 0 ? '/profile/following_tab' : '/profile/followers_tab';
    appRouteObserver.updateCurrentScreen(screen);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              profileState: context.read<ProfileState>(),
              followersScrollController: _followersScrollController,
              followingScrollController: _followingScrollController,
            );
        }
      },
    );
  }

  Widget _buildLoadingScreen(FollowersState followersState) {
    return WillPopScope(
      onWillPop: () async {
        followersState.navigateBack();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(""),
          centerTitle: false,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: "Following"),
              Tab(text: "Followers"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
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
    );
  }

  Widget _buildScreen(
    BuildContext context, {
    required FollowersState followersState,
    required ProfileState profileState,
    required ScrollController followersScrollController,
    required ScrollController followingScrollController,
  }) {
    return WillPopScope(
      onWillPop: () async {
        followersState.navigateBack();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(""),
          centerTitle: false,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Following"),
              Tab(text: "Followers"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            followersState.following.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(15),
                    child: CenterText(text: "Not following anyone."),
                  )
                : ListView(
                    controller: followingScrollController,
                    children: followersState.following.map(
                      (f) {
                        return ListTile(
                          leading: CircularProfilePicture(
                            radius: 20,
                            profilePictureURL: f.targetProfilePictureURL,
                            profileUid: f.targetId,
                          ),
                          title: Text(f.targetDisplayName ?? ""),
                          trailing: UserTrailingButton(
                            profileUserId: f.targetId,
                            profileUserDisplayName: f.targetDisplayName ?? "",
                            profileUserPictureURL: f.targetProfilePictureURL ?? "",
                          ),
                          onTap: () {
                            profileState.loadProfileFromUserId(userId: f.targetId);
                            Navigator.of(context).pushNamed(ProfileScreen.route);
                          },
                        );
                      },
                    ).toList(),
                  ),
            followersState.followers.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(15),
                    child: CenterText(text: "No followers."),
                  )
                : ListView(
                    controller: followersScrollController,
                    children: followersState.followers.map(
                      (f) {
                        return ListTile(
                          leading: CircularProfilePicture(
                            radius: 20,
                            profilePictureURL: f.sourceProfilePictureURL,
                            profileUid: f.sourceId,
                          ),
                          title: Text(f.sourceDisplayName ?? ""),
                          trailing: UserTrailingButton(
                            profileUserId: f.sourceId,
                            profileUserDisplayName: f.sourceDisplayName ?? "",
                            profileUserPictureURL: f.sourceProfilePictureURL ?? "",
                          ),
                          onTap: () {
                            profileState.loadProfileFromUserId(userId: f.sourceId);
                            Navigator.of(context).pushNamed(ProfileScreen.route);
                          },
                        );
                      },
                    ).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
