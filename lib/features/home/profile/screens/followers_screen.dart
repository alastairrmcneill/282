import 'package:flutter/material.dart';

class FollowersFollowingScreen extends StatelessWidget {
  const FollowersFollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Munros"),
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
            Center(child: Text("Following")),
            Center(child: Text("Followers")),
          ],
        ),
      ),
    );
  }
}
