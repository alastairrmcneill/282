import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/profile_stat.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/screens/profile/screens/screens.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileState profileState = Provider.of<ProfileState>(context);

    return SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircularProfilePicture(
                    radius: 50,
                    profilePictureURL: profileState.user?.profilePictureURL,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileState.user?.displayName ?? "Hello user!",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          profileState.user?.bio ?? "",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProfileStat(
                        text: "Following",
                        stat: profileState.user?.followingCount.toString() ?? "0",
                        onTap: () {
                          FollowingService.loadInitialFollowersAndFollowing(
                            context,
                            userId: profileState.user!.uid!,
                          );
                          Navigator.of(context).pushNamed(FollowersFollowingScreen.route);
                        },
                      ),
                      const SizedBox(width: 10),
                      ProfileStat(
                        text: "Followers",
                        stat: profileState.user?.followersCount.toString() ?? "0",
                        onTap: () {
                          FollowingService.loadInitialFollowersAndFollowing(
                            context,
                            userId: profileState.user!.uid!,
                          );
                          Navigator.of(context).pushNamed(FollowersFollowingScreen.route);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      profileState.isCurrentUser
                          ? ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(EditProfileScreen.route);
                              },
                              child: const Text('Edit profile'),
                            )
                          : FollowingButton(
                              isFollowing: profileState.isFollowing,
                              user: profileState.user,
                            ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 36,
                        width: 36,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(UserSearchScreen.route);
                          },
                          child: const Center(child: Icon(Icons.person_search)),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
