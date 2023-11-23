import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  late ScrollController _scrollController;
  @override
  void initState() {
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          feedState.status != FeedStatus.paginating) {
        PostService.paginateFeed(context);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedState>(
      builder: (context, feedState, child) {
        switch (feedState.status) {
          case FeedStatus.loading:
            return Scaffold(
              appBar: AppBar(),
              body: const LoadingWidget(),
            );
          case FeedStatus.error:
            return Scaffold(
              appBar: AppBar(),
              body: CenterText(text: feedState.error.message),
            );
          default:
            return _buildScreen(context, feedState);
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, FeedState feedState) {
    NotificationsState notificationsState = Provider.of<NotificationsState>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              NotificationsService.getUserNotifications(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                notificationsState.notifications.where((element) => !element.read).isEmpty
                    ? const SizedBox()
                    : Positioned(
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            notificationsState.notifications.where((element) => !element.read).length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserSearchScreen(),
                ),
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                feedState.posts.isEmpty
                    ? const SafeArea(
                        child: CenterText(text: "There are no posts in your feed."),
                      )
                    : Column(
                        children: feedState.posts
                            .map(
                              (Post post) => PostWidget(post: post),
                            )
                            .toList(),
                      ),
                SizedBox(
                  child: feedState.status == FeedStatus.paginating ? const CircularProgressIndicator() : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
