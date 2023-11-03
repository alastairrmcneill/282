// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/profile/screens/screens.dart';
import 'package:two_eight_two/features/home/profile/widgets/widgets.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool loading = true;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  Future loadData() async {
    await FollowingService.getMyFollowers(context);
    await FollowingService.getMyFollowing(context);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[350],
                              image: userState.currentUser?.profilePictureURL == null
                                  ? null
                                  : DecorationImage(
                                      fit: BoxFit.cover,
                                      image: CachedNetworkImageProvider(
                                        userState.currentUser!.profilePictureURL!,
                                      ),
                                    ),
                            ),
                            child: userState.currentUser?.profilePictureURL == null
                                ? ClipOval(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Colors.grey[600],
                                      size: 70,
                                    ),
                                  )
                                : null,
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
