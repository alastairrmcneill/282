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
            print(feedState.error.code);
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
    print(feedState.posts.length);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => UserSearchScreen()));
              },
              icon: Icon(Icons.search))
        ],
      ),
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                feedState.posts.isEmpty
                    ? SafeArea(child: CenterText(text: "There were no posts to view."))
                    : Column(
                        children: feedState.posts
                            .map(
                              (Post post) => PostWidget(post: post),
                            )
                            .toList(),
                      ),
                SizedBox(
                  child: feedState.status == FeedStatus.paginating ? CircularProgressIndicator() : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
