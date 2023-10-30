import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/profile/screens/screens.dart';
import 'package:two_eight_two/features/home/profile/widgets/widgets.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                    ),
                  ],
                ),
              ),
              title: Text(
                userState.currentUser?.displayName ?? "Hello User!",
                style: const TextStyle(color: Colors.black),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.all(16),
              collapseMode: CollapseMode.pin,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.3, color: Colors.black54),
                      color: Colors.white,
                      shape: BoxShape.circle),
                  child: IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(2),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.settings,
                      size: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MunroProgressIndicator(),
                  SizedBox(height: 20),
                  FollowersFollowingText(),
                  SizedBox(height: 20),
                  ProfileMediaHistory(),
                  Container(
                    height: 400,
                    width: double.infinity,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
