import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class GroupFilterScreen extends StatefulWidget {
  const GroupFilterScreen({super.key});

  @override
  State<GroupFilterScreen> createState() => _GroupFilterScreenState();
}

class _GroupFilterScreenState extends State<GroupFilterScreen> {
  late ScrollController _followingScrollController;
  @override
  void initState() {
    final user = Provider.of<AppUser?>(context, listen: false);
    FollowersState followersState = Provider.of<FollowersState>(context, listen: false);
    _followingScrollController = ScrollController();
    _followingScrollController.addListener(() {
      if (_followingScrollController.offset >= _followingScrollController.position.maxScrollExtent &&
          !_followingScrollController.position.outOfRange &&
          followersState.status != FollowersStatus.paginating) {
        FollowingService.paginateFollowing(context, userId: user?.uid ?? '');
      }
    });
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load start of friends list

      if (user == null) {
        Navigator.pop(context);
      }

      FollowingService.loadInitialFollowersAndFollowing(context, userId: user?.uid ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Search'),
      ),
      body: Consumer<FollowersState>(
        builder: (context, followersState, child) {
          switch (followersState.status) {
            case FollowersStatus.loading:
              return _buildLoadingScreen(followersState);
            case FollowersStatus.error:
              return CenterText(text: followersState.error.message);
            default:
              return _buildScreen(
                context,
                followersState: followersState,
                followingScrollController: _followingScrollController,
              );
          }
        },
      ),
    );
  }

  Widget _buildLoadingScreen(FollowersState followersState) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 30,
      itemBuilder: (context, index) => const ShimmerListTile(),
    );
  }

  Widget _buildScreen(
    BuildContext context, {
    required FollowersState followersState,
    required ScrollController followingScrollController,
  }) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: followersState.following.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(15),
                    child: CenterText(text: "Not following anyone."),
                  )
                : ListView(
                    controller: followingScrollController,
                    children: followersState.following
                        .map(
                          (followingRelationship) => ListTile(
                            leading: CircularProfilePicture(
                              radius: 20,
                              profilePictureURL: followingRelationship.targetProfilePictureURL,
                              profileUid: followingRelationship.targetId,
                            ),
                            title: Text(
                              followingRelationship.targetDisplayName,
                            ),
                            trailing: null,
                            onTap: () {},
                          ),
                        )
                        .toList(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text("Clear"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Select # friends"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
