import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ProfileTab extends StatelessWidget {
  static const String route = '/profile_tab';
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthState>();
    final userId = auth.currentUserId;

    if (userId == null) {
      // No auth, no ProfileState
      return const CenterText(text: 'Please log in');
    }

    return ChangeNotifierProvider<ProfileState>(
      create: (ctx) => ProfileState(
        ctx.read<ProfileRepository>(),
        ctx.read<MunroPicturesRepository>(),
        ctx.read<PostsRepository>(),
        ctx.read<UserState>(),
        ctx.read<UserLikeState>(),
        ctx.read<MunroCompletionsRepository>(),
      )..loadProfileFromUserId(userId: userId),
      child: Scaffold(
        body: ProfileScreen(
          userId: userId,
        ),
      ),
    );
  }
}
