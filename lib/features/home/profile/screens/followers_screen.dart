import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class FollowersFollowingScreen extends StatefulWidget {
  const FollowersFollowingScreen({super.key});

  @override
  State<FollowersFollowingScreen> createState() => _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen> {
  @override
  Widget build(BuildContext context) {
    FollowingState followingState = Provider.of<FollowingState>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(""),
          centerTitle: false,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Following"),
              Tab(text: "Followers"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: followingState.myFollowing!
                  .map((followingRelationship) => ListTile(title: Text(followingRelationship.targetDisplayName)))
                  .toList(),
            ),
            ListView(
              children: followingState.myFollowing!
                  .map((followingRelationship) => ListTile(title: Text(followingRelationship.targetDisplayName)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
