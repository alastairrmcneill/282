import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ProfileTab extends StatelessWidget {
  static const String route = '/profile_tab';
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileState>(
      create: (ctx) {
        final user = ctx.read<AppUser?>();
        final state = ProfileState(
          ctx.read<ProfileRepository>(),
          ctx.read<MunroPicturesRepository>(),
          ctx.read<PostsRepository>(),
          ctx.read<UserState>(),
          ctx.read<UserLikeState>(),
          ctx.read<MunroCompletionsRepository>(),
        );

        if (user != null) {
          state.loadProfileFromUserId(userId: user.uid!);
        }

        return state;
      },
      child: Builder(
        builder: (ctx) {
          final user = ctx.watch<AppUser?>();
          if (user == null) {
            // If user logs out while on profile tab, you decide what to show
            return const CenterText(text: 'Please log in');
          }
          return Scaffold(
            body: ProfileScreen(
              userId: user.uid!,
            ),
          );
        },
      ),
    );
  }
}
