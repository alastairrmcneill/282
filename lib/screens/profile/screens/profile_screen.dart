import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ProfileScreenArgs {
  final String userId;
  ProfileScreenArgs({required this.userId});
}

class ProfileScreen extends StatefulWidget {
  final String userId;
  static const String route = '/profile';
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _outerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    _outerScrollController.dispose();
    super.dispose();
  }

  void _onTabChange() {
    if (_tabController.indexIsChanging) return;
    if (_outerScrollController.hasClients &&
        _outerScrollController.position.hasContentDimensions &&
        _outerScrollController.position.maxScrollExtent > 0) {
      _outerScrollController.jumpTo(_outerScrollController.position.maxScrollExtent);
    }
  }

  void _showActionsDialog(BuildContext context) {
    final reportState = context.read<ReportState>();
    showActionSheet(context, [
      ActionMenuItems(
        title: 'Block',
        isDestructive: true,
        onPressed: () async {
          showConfirmationDialog(
            context,
            message: "Are you sure you want to block this user?",
            onConfirm: () async {
              await context.read<UserState>().blockUser(userId: widget.userId);
              if (context.mounted) Navigator.of(context).pop();
            },
          );
        },
      ),
      ActionMenuItems(
        title: 'Report',
        isDestructive: true,
        onPressed: () {
          reportState.setContentId = widget.userId;
          reportState.setType = 'user';
          Navigator.of(context).pushNamed(ReportScreen.route);
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileState>(
      builder: (context, profileState, _) {
        if (profileState.status == ProfileStatus.loading) {
          return const _LoadingScreen();
        }
        if (profileState.status == ProfileStatus.error) {
          return Scaffold(
            appBar: AppBar(),
            body: CenterText(text: profileState.error.message),
          );
        }
        return _buildScreen(context, profileState);
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, ProfileState profileState) {
    return AppBar(
      title: Text(profileState.profile?.displayName ?? ''),
      centerTitle: true,
      leading: profileState.isCurrentUser
          ? null
          : IconButton(
              icon: Icon(PhosphorIconsRegular.caretLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
      actions: [
        profileState.isCurrentUser
            ? IconButton(
                onPressed: () => Navigator.of(context).pushNamed(SettingsScreen.route),
                icon: Icon(PhosphorIconsRegular.gear),
              )
            : IconButton(
                icon: Icon(PhosphorIconsBold.dotsThreeVertical, color: context.colors.textMuted),
                onPressed: () => _showActionsDialog(context),
              ),
      ],
    );
  }

  Widget _buildScreen(BuildContext context, ProfileState profileState) {
    final currentUserFollowerState = context.watch<CurrentUserFollowerState>();
    final userLikeState = context.read<UserLikeState>();
    final canViewContent = profileState.isCurrentUser || currentUserFollowerState.isFollowing(widget.userId);

    if (!canViewContent) {
      return Scaffold(
        appBar: _buildAppBar(context, profileState),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const ProfileHeaderSection(),
              _PrivateAccountMessage(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, profileState),
      body: RefreshIndicator(
        onRefresh: () async => profileState.loadProfileFromUserId(userId: widget.userId),
        child: NestedScrollView(
          controller: _outerScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            const SliverToBoxAdapter(child: ProfileHeaderSection()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const ProfileMunroProgressCard(),
                    const SizedBox(height: 12),
                    if (profileState.isCurrentUser) ...[
                      const ProfileLogPastCard(),
                      const SizedBox(height: 12),
                    ],
                    const ProfileChallengeCard(),
                    const SizedBox(height: 12),
                    if (profileState.isCurrentUser) ...[
                      const ProfileAchievementsCard(),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(_tabController),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _PostsTab(profileState: profileState, userLikeState: userLikeState),
              const ProfilePhotosWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  _TabBarDelegate(this.tabController);

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        tabs: const [Tab(text: 'Posts'), Tab(text: 'Photos')],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.tabController != tabController;
}

class _PostsTab extends StatelessWidget {
  final ProfileState profileState;
  final UserLikeState userLikeState;

  const _PostsTab({required this.profileState, required this.userLikeState});

  @override
  Widget build(BuildContext context) {
    if (profileState.posts.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CenterText(text: 'No posts yet')),
            ),
          ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 300 &&
            context.read<ProfileState>().status != ProfileStatus.paginating) {
          context.read<ProfileState>().paginateProfilePosts();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = profileState.posts[index];
                return PostWidget(
                  post: post,
                  inFeed: false,
                  onEdit: () async {
                    final createPostState = context.read<CreatePostState>();
                    final settingsState = context.read<SettingsState>();
                    createPostState.reset();
                    createPostState.loadPost = post;
                    createPostState.setPostPrivacy = settingsState.defaultPostVisibility;
                    final result = await Navigator.of(context).pushNamed(CreatePostScreen.route);
                    if (result is Post) {
                      context.read<ProfileState>().updatePost(result);
                    }
                  },
                  onDelete: () async {
                    final createPostState = context.read<CreatePostState>();
                    await createPostState.deletePost(post: post);
                    context.read<ProfileState>().removePost(post);
                  },
                  onLikeTap: () async {
                    if (userLikeState.likedPosts.contains(post.uid)) {
                      userLikeState.unLikePost(
                        post: post,
                        onPostUpdated: context.read<ProfileState>().updatePost,
                      );
                    } else {
                      userLikeState.likePost(
                        post: post,
                        onPostUpdated: context.read<ProfileState>().updatePost,
                      );
                    }
                  },
                );
              },
              childCount: profileState.posts.length,
            ),
          ),
          if (profileState.status == ProfileStatus.paginating) const SliverToBoxAdapter(child: PaginationLoader()),
          const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
        ],
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShimmerBox(width: 120, height: 18, borderRadius: 4),
        centerTitle: true,
      ),
      body: const CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          LoadingSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 140, borderRadius: 12),
                  SizedBox(height: 12),
                  ShimmerBox(width: double.infinity, height: 140, borderRadius: 12),
                  SizedBox(height: 12),
                  ShimmerBox(width: double.infinity, height: 180, borderRadius: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivateAccountMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, color: context.colors.textMuted),
            const SizedBox(height: 8),
            Text(
              'You are not following this user',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
