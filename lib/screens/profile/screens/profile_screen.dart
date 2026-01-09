import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
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

class _ProfileScreenState extends State<ProfileScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    final profileState = context.read<ProfileState>();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          profileState.status != ProfileStatus.paginating) {
        profileState.paginateProfilePosts();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildPopUpMenu(
    BuildContext context, {
    required ProfileState profileState,
  }) {
    final reportState = context.read<ReportState>();
    List<MenuItem> menuItems = [];

    menuItems = [
      MenuItem(
        text: 'Block',
        onTap: () {
          showConfirmationDialog(
            context,
            message: "Are you sure you want to block this user?",
            onConfirm: () async {
              await context.read<UserState>().blockUser(userId: profileState.profile?.id ?? "");
              Navigator.of(context).pop();
            },
          );
        },
      ),
      MenuItem(
        text: 'Report',
        onTap: () {
          reportState.setContentId = profileState.profile?.id ?? "";
          reportState.setType = "user";
          Navigator.of(context).pushNamed(ReportScreen.route);
        },
      ),
    ];

    return PopupMenuBase(items: menuItems);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileState>(
      builder: (context, profileState, child) {
        switch (profileState.status) {
          case ProfileStatus.loading:
            return _buildLoadingScreen(profileState);
          case ProfileStatus.error:
            print(profileState.error.code);
            return Scaffold(
              appBar: AppBar(),
              body: CenterText(text: profileState.error.message),
            );
          default:
            return _buildScreen(context, profileState);
        }
      },
    );
  }

  Widget _buildLoadingScreen(ProfileState profileState) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: NeverScrollableScrollPhysics(),
        slivers: [
          LoadingSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 300, height: 24, borderRadius: 5),
                  SizedBox(height: 20),
                  ShimmerBox(
                    width: double.infinity,
                    height: 40,
                    borderRadius: 5,
                  ),
                  SizedBox(height: 20),
                  ShimmerPostTile(),
                  ShimmerPostTile(),
                  ShimmerPostTile(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScreen(BuildContext context, ProfileState profileState) {
    UserLikeState userLikeState = context.read<UserLikeState>();
    CurrentUserFollowerState currentUserFollowerState = context.watch<CurrentUserFollowerState>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 35,
        elevation: 0,
        actions: [
          profileState.isCurrentUser
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(SettingsScreen.route);
                  },
                  icon: const Icon(Icons.settings_rounded),
                )
              : _buildPopUpMenu(context, profileState: profileState)
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          profileState.loadProfileFromUserId(userId: profileState.profile?.id ?? "");
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const ProfileHeader(),
              const PaddedDivider(left: 15, right: 15),
              !(profileState.isCurrentUser || currentUserFollowerState.isFollowing(widget.userId))
                  ? const SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.lock),
                            Text('You are not following this user'),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        const ProfileMunroStats(),
                        const PaddedDivider(left: 15, right: 15),
                        const ProfilePhotosWidget(),
                        const PaddedDivider(
                          top: 20,
                          left: 15,
                          right: 15,
                          bottom: 5,
                        ),
                        profileState.posts.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: CenterText(text: "No posts"),
                              )
                            : Column(
                                children: profileState.posts
                                    .map(
                                      (Post post) => PostWidget(
                                        post: post,
                                        inFeed: false,
                                        onEdit: () async {
                                          final createPostState = context.read<CreatePostState>();
                                          final settingsState = context.read<SettingsState>();

                                          createPostState.reset();
                                          createPostState.loadPost = post;
                                          createPostState.setPostPrivacy = settingsState.defaultPostVisibility;

                                          final updated = await Navigator.of(context).pushNamed<Post>(
                                            CreatePostScreen.route,
                                          );

                                          if (updated != null) {
                                            context.read<ProfileState>().updatePost(updated);
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
                                              onPostUpdated: profileState.updatePost,
                                            );
                                          } else {
                                            userLikeState.likePost(
                                              post: post,
                                              onPostUpdated: profileState.updatePost,
                                            );
                                          }
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
