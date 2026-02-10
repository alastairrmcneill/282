import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/logging/logging.dart';
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
        ctx.read<Logger>(),
      )..loadProfileFromUserId(userId: userId),
      child: Scaffold(
        body: Column(
          children: [
            Column(
              children: [
                Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
                Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
                Text('Body Small', style: Theme.of(context).textTheme.bodySmall),
                Text('Display Large', style: Theme.of(context).textTheme.displayLarge),
                Text('Display Medium', style: Theme.of(context).textTheme.displayMedium),
                Text('Display Small', style: Theme.of(context).textTheme.displaySmall),
                Text('Headline Large', style: Theme.of(context).textTheme.headlineLarge),
                Text('Headline Medium', style: Theme.of(context).textTheme.headlineMedium),
                Text('Headline Small', style: Theme.of(context).textTheme.headlineSmall),
                Text('Label Large', style: Theme.of(context).textTheme.labelLarge),
                Text('Label Medium', style: Theme.of(context).textTheme.labelMedium),
                Text('Label Small', style: Theme.of(context).textTheme.labelSmall),
                Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
                Text('Title Medium', style: Theme.of(context).textTheme.titleMedium),
                Text('Title Small', style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ],
        ),
        // ProfileScreen(
        //   userId: userId,
        // ),
      ),
    );
  }
}
