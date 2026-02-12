import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FeedListView extends StatefulWidget {
  final List<Post> posts;
  final VoidCallback paginate;
  final VoidCallback refreshPosts;
  final Widget? headerWidget;
  final Widget? emptyList;
  const FeedListView({
    super.key,
    required this.posts,
    required this.paginate,
    required this.refreshPosts,
    this.headerWidget,
    this.emptyList,
  });
  static const String route = '/feed/list';

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedState>(
      builder: (context, feedState, child) {
        switch (feedState.status) {
          case FeedStatus.loading:
            return _buildLoadingScreen(context, feedState);

          case FeedStatus.error:
            return CenterText(text: feedState.error.message);
          default:
            return _buildScreen(context, feedState);
        }
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context, FeedState feedState) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) => const ShimmerPostTile(),
    );
  }

  Widget _buildScreen(BuildContext context, FeedState feedState) {
    UserLikeState userLikeState = context.read<UserLikeState>();
    const postsFromEndToPaginate = 2;

    if (widget.posts.isEmpty) {
      return widget.emptyList ??
          Padding(
            padding: EdgeInsets.all(15),
            child: CenterText(
              text:
                  "There are no posts to show. Get out into the hills with your friends and start making some memories!",
            ),
          );
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.refreshPosts();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.posts.length + 2, // +1 for header, +1 for loading indicator
        itemBuilder: (context, index) {
          // Header widget
          if (index == 0) {
            return widget.headerWidget ?? const SizedBox.shrink();
          }

          // Loading indicator at the bottom
          if (index == widget.posts.length + 1) {
            return SizedBox(
              child: feedState.status == FeedStatus.paginating ? const CircularProgressIndicator() : null,
            );
          }

          // Post items
          final postIndex = index - 1;
          final post = widget.posts[postIndex];

          // Trigger pagination when reaching 2 posts from the end
          if (postIndex >= widget.posts.length - postsFromEndToPaginate && feedState.status != FeedStatus.paginating) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.paginate();
            });
          }
          return PostWidget(
            post: post,
            inFeed: true,
            onEdit: () async {
              final createPostState = context.read<CreatePostState>();
              final settingsState = context.read<SettingsState>();

              createPostState.reset();
              createPostState.loadPost = post;
              createPostState.setPostPrivacy = settingsState.defaultPostVisibility;

              final result = await Navigator.of(context).pushNamed(
                CreatePostScreen.route,
              );

              if (result is Post) {
                context.read<FeedState>().updatePost(result);
              }
            },
            onDelete: () async {
              final createPostState = context.read<CreatePostState>();
              await createPostState.deletePost(post: post);

              context.read<FeedState>().removePost(post);
            },
            onLikeTap: () async {
              if (userLikeState.likedPosts.contains(post.uid)) {
                userLikeState.unLikePost(
                  post: post,
                  onPostUpdated: feedState.updatePost,
                );
              } else {
                userLikeState.likePost(
                  post: post,
                  onPostUpdated: feedState.updatePost,
                );
              }
            },
          );
        },
      ),
    );
  }
}
