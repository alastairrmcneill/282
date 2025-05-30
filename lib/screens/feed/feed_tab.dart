import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:two_eight_two/screens/feed/screens/feed_list_view.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/support/app_route_observer.dart';

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});
  static const String route = '/feed_tab';

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // Initialize TabController
    _tabController = TabController(length: 2, vsync: this);

    // Log the first tab on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logTabAnalytics(_tabController.index);

      // RateMyApp logic
      RateMyApp rateMyApp = RateMyApp(
        preferencesPrefix: 'rateMyApp_',
        minDays: 2,
        minLaunches: 2,
        remindDays: 5,
        remindLaunches: 5,
      );

      rateMyApp.init().then((_) {
        if (mounted && rateMyApp.shouldOpenDialog) {
          rateMyApp.showRateDialog(context);
        }
      });
    });

    // Listen for tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // Wait for animation to complete
      _logTabAnalytics(_tabController.index);
    });
  }

  void _logTabAnalytics(int index) {
    final screenName = index == 0 ? '/feed_tab/global' : '/feed_tab/friends';
    appRouteObserver.updateCurrentScreen(screenName);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FeedState feedState = Provider.of<FeedState>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TabBar(
                  controller: _tabController,
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
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'All Munro Baggers'),
                    Tab(text: 'Friends'),
                  ],
                ),
                const Spacer(),
                const NotificationIconButton(),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            FeedListView(
              posts: feedState.globalPosts,
              paginate: () => PostService.paginateGlobalFeed(context),
              refreshPosts: () => PostService.getGlobalFeed(context),
            ),
            FeedListView(
              posts: feedState.friendsPosts,
              paginate: () => PostService.paginateFriendsFeed(context),
              refreshPosts: () => PostService.getFriendsFeed(context),
              headerWidget: const FindFriendsHeaderWiget(),
              emptyList: const EmptyFriendsFeed(),
            ),
          ],
        ),
      ),
    );
  }
}
