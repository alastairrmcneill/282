import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/group_filter/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'package:two_eight_two/widgets/pagination_loader.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class GroupFilterTab extends StatefulWidget {
  const GroupFilterTab({super.key});
  static const String route = '/group_filter_tab';

  @override
  State<GroupFilterTab> createState() => _GroupFilterTabState();
}

class _GroupFilterTabState extends State<GroupFilterTab> {
  late ScrollController _scrollController;
  final FocusNode _focusNode = FocusNode();
  String _currentQuery = '';

  @override
  void initState() {
    final groupFilterState = context.read<GroupFilterState>();

    context.read<AppRouteObserver>().updateCurrentScreen(GroupFilterTab.route);

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          groupFilterState.status != GroupFilterStatus.paginating) {
        groupFilterState.paginateSearch(query: _currentQuery);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupFilterState = context.read<GroupFilterState>();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: AppSearchBar(
              focusNode: _focusNode,
              hintText: "Find friends",
              onClear: () {
                setState(() => _currentQuery = '');
                groupFilterState.clearSearch();
              },
              onSearchTap: () {},
              onChanged: (q) {
                setState(() => _currentQuery = q);
                if (q.length >= 2) groupFilterState.search(query: q);
              },
            ),
          ),
          const SelectedFriendsScroll(),
          Expanded(
            child: _currentQuery.isEmpty
                ? Consumer<GroupFilterState>(
                    builder: (context, state, child) {
                      return state.selectedFriends.isEmpty
                          ? const GroupFilterInfoView()
                          : const GroupFilterSelectionPrompt();
                    },
                  )
                : Consumer<GroupFilterState>(
                    builder: (context, state, child) {
                      if (state.status == GroupFilterStatus.loading) {
                        return _FriendListLoading();
                      }
                      if (state.status == GroupFilterStatus.error) {
                        return CenterText(text: state.error.message);
                      }
                      return _FriendList(
                        groupFilterState: state,
                        scrollController: _scrollController,
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Consumer<GroupFilterState>(
        builder: (context, state, child) {
          return GroupFilterBottomBar(
            selectedCount: state.selectedFriendsUids.length,
            onClear: state.clearSelection,
            onConfirm: state.selectedFriendsUids.isNotEmpty
                ? () async {
                    context.read<Analytics>().track(AnalyticsEvent.groupViewFilterApplied);
                    await state.filterMunrosBySelection();
                    homeScreenKey.currentState?.switchTab(0);
                  }
                : null,
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Consumer<GroupFilterState>(
        builder: (context, state, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Friends"),
              if (state.selectedFriendsUids.isNotEmpty)
                Text(
                  "${state.selectedFriendsUids.length} selected",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSubtitle,
                      ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FriendListLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 12,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => const ShimmerListTile(),
    );
  }
}

class _FriendList extends StatelessWidget {
  final GroupFilterState groupFilterState;
  final ScrollController scrollController;

  const _FriendList({
    required this.groupFilterState,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (groupFilterState.friends.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CenterText(text: "No results found, try another search."),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: groupFilterState.friends.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == groupFilterState.friends.length) {
          return groupFilterState.status == GroupFilterStatus.paginating
              ? const PaginationLoader()
              : const SizedBox.shrink();
        }
        final friend = groupFilterState.friends[index];
        final isSelected = groupFilterState.selectedFriendsUids.contains(friend.targetId);
        return FriendListTile(
          friend: friend,
          isSelected: isSelected,
          onTap: () {
            if (isSelected) {
              groupFilterState.removeSelectedFriend(uid: friend.targetId);
            } else {
              groupFilterState.addSelectedFriend(friend: friend);
            }
          },
        );
      },
    );
  }
}
