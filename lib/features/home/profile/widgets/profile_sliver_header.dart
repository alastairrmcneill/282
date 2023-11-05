import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/profile/screens/screens.dart';
import 'package:two_eight_two/features/home/widgets/widgets.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class ProfileSliverHeader extends StatefulWidget {
  const ProfileSliverHeader({super.key});

  @override
  State<ProfileSliverHeader> createState() => _ProfileSliverHeaderState();
}

class _ProfileSliverHeaderState extends State<ProfileSliverHeader> {
  @override
  Widget build(BuildContext context) {
    ProfileState profileState = Provider.of<ProfileState>(context);

    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      actions: !profileState.isCurrentUser
          ? []
          : [
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
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate the percentage of the AppBar's size as it collapses
          double percentage = (constraints.biggest.height - kToolbarHeight) / (180.0 - kToolbarHeight);
          // Ensure the percentage is between 0 and 1
          percentage = 1 - percentage.clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            title: Opacity(
              opacity: percentage,
              child: Text(
                profileState.user?.displayName ?? "Hello User!",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            centerTitle: false,
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CirculeProfilePicture(
                          radius: 50,
                          profilePictureURL: profileState.user?.profilePictureURL,
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              StatText(
                                text: "Munros",
                                stat: profileState.user?.personalMunroData
                                        ?.where((munro) => munro[MunroFields.summited])
                                        .length ??
                                    0,
                              ),
                              StatText(
                                text: "Following",
                                stat: profileState.user?.followingCount ?? 0,
                                onTap: () {
                                  FollowingService.getFollowersAndFollowing(context, userId: profileState.user!.uid!);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const FollowersFollowingScreen(),
                                    ),
                                  );
                                },
                              ),
                              StatText(
                                text: "Followers",
                                stat: profileState.user?.followersCount ?? 0,
                                onTap: () {
                                  FollowingService.getFollowersAndFollowing(context, userId: profileState.user!.uid!);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const FollowersFollowingScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        profileState.user?.displayName ?? "Hello users!",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: "NotoSans",
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
