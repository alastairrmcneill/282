import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro_challenge/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          profileState.status != ProfileStatus.paginating) {
        PostService.paginateProfilePosts(context);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileState>(
      builder: (context, profileState, child) {
        switch (profileState.status) {
          case ProfileStatus.loading:
            return _buildLoadingScreen(profileState);
          case ProfileStatus.error:
            print(profileState.error.code);
            return Scaffold(
              appBar: AppBar(),
              body: CenterText(text: profileState.error.message),
            );
          default:
            return _buildScreen(context, profileState);
        }
      },
    );
  }

  Widget _buildLoadingScreen(ProfileState profileState) {
    return WillPopScope(
      onWillPop: () async {
        profileState.navigateBack();
        return true;
      },
      child: const Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          physics: NeverScrollableScrollPhysics(),
          slivers: [
            LoadingSliverHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 300, height: 24, borderRadius: 5),
                    SizedBox(height: 20),
                    ShimmerBox(
                      width: double.infinity,
                      height: 40,
                      borderRadius: 5,
                    ),
                    SizedBox(height: 20),
                    ShimmerPostTile(),
                    ShimmerPostTile(),
                    ShimmerPostTile(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, ProfileState profileState) {
    FlavorState flavorState = Provider.of<FlavorState>(context);

    if (profileState.isCurrentUser) showGoToBulkMunroDialog(context);

    return WillPopScope(
      onWillPop: () async {
        profileState.navigateBack();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            ProfileService.loadUserFromUid(context, userId: profileState.user?.uid ?? "");
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const ProfileSliverHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      profileState.user?.bio != null ? Text(profileState.user!.bio!) : const SizedBox(),
                      profileState.isCurrentUser
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                                      );
                                    },
                                    child: Text('Edit profile'),
                                  ),
                                ),
                                flavorState.flavor == "Production" ? const SizedBox() : const SizedBox(width: 15),
                                flavorState.flavor == "Production"
                                    ? const SizedBox()
                                    : Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              print('Share');
                                              // await FirebaseMessaging.instance.requestPermission();
                                              // final token = await FirebaseMessaging.instance.getToken();
                                            } catch (error, stackTrace) {
                                              Log.error(error.toString(), stackTrace: stackTrace);
                                            }
                                          },
                                          child: Text('Share profile'),
                                        ),
                                      ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: FollowingButton(
                                    isFollowing: profileState.isFollowing,
                                    user: profileState.user,
                                  ),
                                ),
                                flavorState.flavor == "Production" ? const SizedBox() : const SizedBox(width: 15),
                                flavorState.flavor == "Production"
                                    ? const SizedBox()
                                    : Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            try {
                                              print('Share');
                                              // await FirebaseMessaging.instance.requestPermission();
                                              // final token = await FirebaseMessaging.instance.getToken();
                                            } on Exception catch (error, stackTrace) {
                                              Log.error(error.toString(), stackTrace: stackTrace);
                                            }
                                          },
                                          child: Text('Share profile'),
                                        ),
                                      ),
                              ],
                            ),
                      const SizedBox(height: 20),
                      !(profileState.isCurrentUser || profileState.isFollowing)
                          ? const SizedBox()
                          : Column(
                              children: [
                                const MunroChallengeWidget(),
                                profileState.posts.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                        child: CenterText(text: "No posts"),
                                      )
                                    : Column(
                                        children:
                                            profileState.posts.map((Post post) => PostWidget(post: post)).toList(),
                                      ),
                              ],
                            ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
