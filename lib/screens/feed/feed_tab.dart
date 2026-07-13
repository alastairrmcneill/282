import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/feed/screens/feed_list_view.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'package:two_eight_two/support/review_prompt.dart';

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

      maybeShowReviewPrompt(context);
    });

    // Listen for tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // Wait for animation to complete
      _logTabAnalytics(_tabController.index);
    });
  }

  void _logTabAnalytics(int index) {
    final screenName = index == 0 ? '/feed_tab/global' : '/feed_tab/friends';
    context.read<AppRouteObserver>().updateCurrentScreen(screenName);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = context.watch<FeedState>();
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
                  dividerColor: context.colors.divider,
                  tabAlignment: TabAlignment.start,
                  labelColor: context.colors.accent,
                  unselectedLabelColor: context.colors.textMuted,
                  indicatorColor: context.colors.accent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: UnderlineTabIndicator(
                    insets: const EdgeInsets.symmetric(horizontal: 8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                    borderSide: BorderSide(
                      color: context.colors.accent,
                      width: 3,
                    ),
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        children: [
                          Icon(PhosphorIconsRegular.globe, size: 18),
                          SizedBox(width: 6),
                          Text('All Baggers'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(PhosphorIconsRegular.users, size: 18),
                          SizedBox(width: 8),
                          Text('Pals'),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const FindFriendsIconButton(),
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
              paginate: () => feedState.paginateGlobalFeed(),
              refreshPosts: () => feedState.getGlobalFeed(),
              headerWidget: const SizedBox(height: 10),
            ),
            FeedListView(
              posts: feedState.friendsPosts,
              paginate: () => feedState.paginateFriendsFeed(),
              refreshPosts: () => feedState.getFriendsFeed(),
              emptyList: const EmptyFriendsFeed(),
            ),
          ],
        ),
      ),
    );
  }
}
