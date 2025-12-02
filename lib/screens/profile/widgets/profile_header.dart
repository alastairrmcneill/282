import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileState profileState = Provider.of<ProfileState>(context);
    final followersState = context.read<FollowersState>();

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
                    profilePictureURL: profileState.profile?.profilePictureURL,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileState.profile?.displayName ?? "Hello user!",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          profileState.profile?.bio ?? "",
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
                        stat: profileState.profile?.followingCount.toString() ?? "0",
                        onTap: () {
                          followersState.loadInitialFollowersAndFollowing(
                            userId: profileState.profile!.id!,
                          );
                          Navigator.of(context).pushNamed(FollowersFollowingScreen.route);
                        },
                      ),
                      const SizedBox(width: 10),
                      ProfileStat(
                        text: "Followers",
                        stat: profileState.profile?.followersCount.toString() ?? "0",
                        onTap: () {
                          followersState.loadInitialFollowersAndFollowing(
                            userId: profileState.profile!.id!,
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
                              profile: profileState.profile,
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
