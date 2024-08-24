import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:two_eight_two/screens/feed/screens/feed_list_view.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  @override
  void initState() {
    RateMyApp rateMyApp = RateMyApp(
      preferencesPrefix: 'rateMyApp_',
      minDays: 2,
      minLaunches: 2,
      remindDays: 5,
      remindLaunches: 5,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rateMyApp.init();
      if (mounted && rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FeedState feedState = Provider.of<FeedState>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TabBar(
                  isScrollable: true,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: MyColors.accentColor,
                      width: 2.0,
                    ),
                    insets: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                  unselectedLabelColor: Colors.grey[600],
                  tabs: const [
                    Tab(text: 'All Munro Baggers'),
                    Tab(text: 'Friends'),
                  ],
                ),
                const Spacer(),
                // FindFriendsIconButton(),
                const NotificationIconButton(),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            FeedListView(
              posts: feedState.globalPosts,
              paginate: () {
                PostService.paginateGlobalFeed(context);
              },
              refreshPosts: () {
                PostService.getGlobalFeed(context);
              },
            ),
            FeedListView(
              posts: feedState.friendsPosts,
              paginate: () {
                PostService.paginateFriendsFeed(context);
              },
              refreshPosts: () {
                PostService.getFriendsFeed(context);
              },
              headerWidget: const FindFriendsHeaderWiget(),
              emptyList: const EmptyFriendsFeed(),
            ),
          ],
        ),
      ),
    );
  }
}
