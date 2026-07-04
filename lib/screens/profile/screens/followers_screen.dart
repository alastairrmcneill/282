// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FollowersFollowingScreenArgs {
  final String userId;

  FollowersFollowingScreenArgs({required this.userId});
}

class FollowersFollowingScreen extends StatefulWidget {
  final String userId;
  static const String route = '/profile/followers';
  const FollowersFollowingScreen({super.key, required this.userId});

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

    final followersListState = context.read<FollowersListState>();

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
          followersListState.status != FollowersListStatus.paginating) {
        followersListState.paginateFollowers(userId: widget.userId);
      }
    });

    _followingScrollController = ScrollController();
    _followingScrollController.addListener(() {
      if (_followingScrollController.offset >= _followingScrollController.position.maxScrollExtent &&
          !_followingScrollController.position.outOfRange &&
          followersListState.status != FollowersListStatus.paginating) {
        followersListState.paginateFollowing(userId: widget.userId);
      }
    });
  }

  void _logTabAnalytics(int index) {
    final screen = index == 0 ? '/profile/following_tab' : '/profile/followers_tab';
    context.read<AppRouteObserver>().updateCurrentScreen(screen);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _followersScrollController.dispose();
    _followingScrollController.dispose();
    super.dispose();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Community"),
      actions: [
        IconButton(
          icon: const Icon(PhosphorIconsRegular.magnifyingGlass),
          onPressed: () => Navigator.of(context).pushNamed(UserSearchScreen.route),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: "Following"),
          Tab(text: "Followers"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowersListState>(
      builder: (context, followersListState, child) {
        switch (followersListState.status) {
          case FollowersListStatus.loading:
            return _buildLoadingScreen();
          case FollowersListStatus.error:
            return Scaffold(
              appBar: _buildAppBar(),
              body: CenterText(text: followersListState.error.message),
            );
          default:
            return _buildScreen(
              context,
              followersListState: followersListState,
              followersScrollController: _followersScrollController,
              followingScrollController: _followingScrollController,
            );
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 20,
            itemBuilder: (context, index) => const ShimmerListTile(),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 20,
            itemBuilder: (context, index) => const ShimmerListTile(),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(
    BuildContext context, {
    required FollowersListState followersListState,
    required ScrollController followersScrollController,
    required ScrollController followingScrollController,
  }) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          followersListState.following.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(15),
                  child: CenterText(text: "Not following anyone yet."),
                )
              : ListView.builder(
                  controller: followingScrollController,
                  itemCount: followersListState.following.length + 1,
                  itemBuilder: (context, index) {
                    if (index == followersListState.following.length) {
                      return followersListState.status == FollowersListStatus.paginating
                          ? const PaginationLoader()
                          : const SizedBox.shrink();
                    }
                    final f = followersListState.following[index];
                    return _UserTile(
                      userId: f.targetId,
                      displayName: f.targetDisplayName ?? "",
                      profilePictureURL: f.targetProfilePictureURL,
                      munrosCompleted: f.targetMunrosCompleted,
                    );
                  },
                ),
          followersListState.followers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(15),
                  child: CenterText(text: "No followers yet."),
                )
              : ListView.builder(
                  controller: followersScrollController,
                  itemCount: followersListState.followers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == followersListState.followers.length) {
                      return followersListState.status == FollowersListStatus.paginating
                          ? const PaginationLoader()
                          : const SizedBox.shrink();
                    }
                    final f = followersListState.followers[index];
                    return _UserTile(
                      userId: f.sourceId,
                      displayName: f.sourceDisplayName ?? "",
                      profilePictureURL: f.sourceProfilePictureURL,
                      munrosCompleted: f.sourceMunrosCompleted,
                    );
                  },
                ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final String userId;
  final String displayName;
  final String? profilePictureURL;
  final int? munrosCompleted;

  const _UserTile({
    required this.userId,
    required this.displayName,
    this.profilePictureURL,
    this.munrosCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        ProfileScreen.route,
        arguments: ProfileScreenArgs(userId: userId),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircularProfilePicture(
              radius: 22,
              profilePictureURL: profilePictureURL,
              profileUid: userId,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: textTheme.titleSmall?.copyWith(color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${munrosCompleted ?? 0} Munros",
                    style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            UserTrailingButton(
              profileUserId: userId,
              profileUserDisplayName: displayName,
              profileUserPictureURL: profilePictureURL ?? "",
            ),
          ],
        ),
      ),
    );
  }
}
