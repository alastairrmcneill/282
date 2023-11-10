import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/feed/widgets/widgets.dart';
import 'package:two_eight_two/features/home/profile/screens/screens.dart';
import 'package:two_eight_two/features/home/profile/widgets/widgets.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/post_service.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

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
            return Scaffold(
              appBar: AppBar(),
              body: const LoadingWidget(),
            );
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

  Widget _buildScreen(BuildContext context, ProfileState profileState) {
    return WillPopScope(
      onWillPop: () async {
        profileState.navigateBack();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
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
                              const SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    print('Share');
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
                              const SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    print('Share');
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
                              const ProfileMediaHistory(),
                              Column(
                                children: profileState.posts
                                    .map(
                                      (e) => SizedBox(
                                        height: 100,
                                        child: ListTile(
                                          title: Text(e.uid ?? ""),
                                          tileColor: Colors.red,
                                        ),
                                      ),
                                    )
                                    .toList(),
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
    );
  }
}
