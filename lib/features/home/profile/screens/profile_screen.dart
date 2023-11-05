import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/feed/widgets/widgets.dart';
import 'package:two_eight_two/features/home/profile/screens/screens.dart';
import 'package:two_eight_two/features/home/profile/widgets/widgets.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/profile_service.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Uh oh, something went wrong. Please try again')),
            );
          case ProfileStatus.loaded:
            return _buildScreen(context, profileState);
          default:
            return Scaffold(appBar: AppBar());
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, ProfileState profileState) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
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
                                user: profileState.user!,
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
                            Container(
                              height: 4000,
                              width: double.infinity,
                              color: Colors.red,
                            ),
                          ],
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
