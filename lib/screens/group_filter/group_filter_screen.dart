import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
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
    final user = Provider.of<AppUser?>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          groupFilterState.status != GroupFilterStatus.paginating) {
        GroupFilterService.paginateSearch(context, query: _searchController.text.trim());
      }
    });

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GroupFilterService.getInitialFriends(context, userId: user?.uid ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomAppBarBackButton(
          onPressed: () {
            GroupFilterService.clearSelection(context);
            Navigator.pop(context);
          },
        ),
        title: AppSearchBar(
          focusNode: _focusNode,
          hintText: "Find friends",
          onClear: () {
            _searchController.clear();
            GroupFilterService.clearSearch(context);
          },
          onSearchTap: () {},
          onChanged: (value) {
            if (value.trim().length >= 2) {
              GroupFilterService.search(context, query: value.trim());
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
                          title: Text(followingRelationship.targetDisplayName),
                          trailing: groupFilterState.selectedFriendsUids.contains(followingRelationship.targetId)
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () {
                            if (groupFilterState.selectedFriendsUids.contains(followingRelationship.targetId)) {
                              groupFilterState.removeSelectedFriend(followingRelationship.targetId);
                            } else {
                              groupFilterState.addSelectedFriend(followingRelationship.targetId);
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
                    GroupFilterService.clearSelection(context);
                  },
                  child: const Text("Clear"),
                ),
                ElevatedButton(
                  onPressed: groupFilterState.selectedFriendsUids.isNotEmpty
                      ? () async {
                          // Run the filter
                          AnalyticsService.logEvent(name: "Group View Filter Applied");
                          await GroupFilterService.filterMunrosBySelection(context);
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
