import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
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

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView> {
  late ScrollController _scrollController;
  @override
  void initState() {
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          feedState.status != FeedStatus.paginating) {
        widget.paginate();
      }
    });

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
    return RefreshIndicator(
      onRefresh: () async {
        widget.refreshPosts();
      },
      child: widget.posts.isEmpty
          ? widget.emptyList ??
              const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: CenterText(
                    text:
                        "There are no posts to show. Get out into the hills with your friends and start making some memories!",
                  ),
                ),
              )
          : ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.headerWidget ?? const SizedBox(),
                    Column(
                      children: widget.posts
                          .map(
                            (Post post) => PostWidget(
                              post: post,
                              inFeed: true,
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(
                      child: feedState.status == FeedStatus.paginating ? const CircularProgressIndicator() : null,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
