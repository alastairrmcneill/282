import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class GroupFilterScreen extends StatefulWidget {
  const GroupFilterScreen({super.key});
  static const String route = '${ExploreTab.route}/group_filter';

  @override
  State<GroupFilterScreen> createState() => _GroupFilterScreenState();
}

class _GroupFilterScreenState extends State<GroupFilterScreen> {
  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context, listen: false);
    final userId = context.read<AuthState>().currentUserId;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          groupFilterState.status != GroupFilterStatus.paginating) {
        groupFilterState.paginateSearch(query: _searchController.text.trim());
      }
    });

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupFilterState.getInitialFriends(userId: userId ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    GroupFilterState groupFilterState = context.read<GroupFilterState>();
    return Scaffold(
      appBar: AppBar(
        leading: CustomAppBarBackButton(
          onPressed: () {
            groupFilterState.clearSelection();
            Navigator.pop(context);
          },
        ),
        title: AppSearchBar(
          focusNode: _focusNode,
          hintText: "Find friends",
          onClear: () {
            _searchController.clear();
            groupFilterState.clearSearch();
          },
          onSearchTap: () {},
          onChanged: (value) {
            if (value.trim().length >= 2) {
              groupFilterState.search(query: value.trim());
            }
          },
        ),
      ),
      body: Consumer<GroupFilterState>(
        builder: (context, groupFilterState, child) {
          switch (groupFilterState.status) {
            case GroupFilterStatus.loading:
              return _buildLoadingScreen(groupFilterState);
            case GroupFilterStatus.error:
              return CenterText(text: groupFilterState.error.message);
            default:
              return _buildScreen(
                context,
                groupFilterState: groupFilterState,
                scrollController: _scrollController,
              );
          }
        },
      ),
    );
  }

  Widget _buildLoadingScreen(GroupFilterState groupFilterState) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 30,
      itemBuilder: (context, index) => const ShimmerListTile(),
    );
  }

  Widget _buildScreen(
    BuildContext context, {
    required GroupFilterState groupFilterState,
    required ScrollController scrollController,
  }) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: groupFilterState.friends.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(15),
                    child: CenterText(text: "No friends found."),
                  )
                : ListView(
                    controller: _scrollController,
                    children: groupFilterState.friends.map(
                      (followingRelationship) {
                        return ListTile(
                          leading: CircularProfilePicture(
                            radius: 20,
                            profilePictureURL: followingRelationship.targetProfilePictureURL,
                            profileUid: followingRelationship.targetId,
                          ),
                          title: Text(followingRelationship.targetDisplayName ?? ""),
                          trailing: groupFilterState.selectedFriendsUids.contains(followingRelationship.targetId)
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () {
                            if (groupFilterState.selectedFriendsUids.contains(followingRelationship.targetId)) {
                              groupFilterState.removeSelectedFriend(uid: followingRelationship.targetId);
                            } else {
                              groupFilterState.addSelectedFriend(uid: followingRelationship.targetId);
                            }
                          },
                        );
                      },
                    ).toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    groupFilterState.clearSelection();
                  },
                  child: const Text("Clear"),
                ),
                ElevatedButton(
                  onPressed: groupFilterState.selectedFriendsUids.isNotEmpty
                      ? () async {
                          // Run the filter
                          AnalyticsService.logEvent(name: "Group View Filter Applied");
                          await groupFilterState.filterMunrosBySelection();
                          Navigator.pop(context);
                        }
                      : null,
                  child: Text(
                      "Select ${groupFilterState.selectedFriendsUids.length} friend${groupFilterState.selectedFriendsUids.length == 1 ? '' : 's'}"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
