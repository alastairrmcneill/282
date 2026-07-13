import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/photo_gallery/state/photo_gallery_state.dart';
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
      return const CenterText(text: 'Please log in');
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileState>(
          create: (ctx) => ProfileState(
            ctx.read<ProfileRepository>(),
            ctx.read<MunroPicturesRepository>(),
            ctx.read<PostsRepository>(),
            ctx.read<UserState>(),
            ctx.read<UserLikeState>(),
            ctx.read<MunroCompletionsRepository>(),
            ctx.read<Logger>(),
          )..loadProfileFromUserId(userId: userId),
        ),
        ChangeNotifierProvider<PhotoGalleryState<MunroPicture>>(
          create: (ctx) => PhotoGalleryState<MunroPicture>(
            ctx.read<UserState>(),
            ctx.read<Logger>(),
            ({required offset, required count, required excludedAuthorIds}) {
              return ctx.read<MunroPicturesRepository>().readProfilePictures(
                    profileId: userId,
                    excludedAuthorIds: excludedAuthorIds,
                    offset: offset,
                    count: count,
                  );
            },
          )..loadInitital(),
        ),
      ],
      child: ProfileScreen(userId: userId),
    );
  }
}
