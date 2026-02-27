import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class EmptyFriendsFeed extends StatelessWidget {
  const EmptyFriendsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 40),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1757038822217-d68becfce696?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzY290dGlzaCUyMG1vdW50YWlucyUyMGZyaWVuZHNoaXAlMjBoaWtpbmd8ZW58MXx8fHwxNzcwODkyNjU0fDA&ixlib=rb-4.1.0&q=80&w=1080',
                    fit: BoxFit.cover,
                    color: Colors.white.withOpacity(0.8),
                    colorBlendMode: BlendMode.modulate,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          theme.scaffoldBackgroundColor,
                          theme.scaffoldBackgroundColor.withOpacity(0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: MyColors.lightGrey,
                    shape: BoxShape.circle,
                  ),
                  width: 90,
                  height: 90,
                  child: Icon(
                    PhosphorIconsRegular.users,
                    size: 40,
                    color: MyColors.mutedText,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: MyColors.lightGrey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    width: 36,
                    height: 36,
                    child: Icon(
                      PhosphorIconsRegular.mountains,
                      size: 18,
                      color: MyColors.mutedText,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: MyColors.lightGrey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    width: 36,
                    height: 36,
                    child: Icon(
                      PhosphorIconsRegular.sparkle,
                      size: 18,
                      color: MyColors.mutedText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Your friends haven\'t hit the hills yet!', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'When your pals start bagging munros, their adventures will show up here. Time to inspire them to get outside and make some memories!',
            style: theme.textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pushNamed(UserSearchScreen.route);
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsRegular.userPlus),
                const SizedBox(width: 8),
                const Text("Find Friends"),
              ],
            ),
          ),
          const SizedBox(height: 4),
          OutlinedButton(
            onPressed: () async {
              final link = await context.read<ShareState>().createAppLink();

              if (link == null) {
                showSnackBar(context, 'Failed to share link.');
                return;
              }

              await SharePlus.instance.share(ShareParams(text: 'Check out 282 - $link'));
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PhosphorIconsRegular.users),
                const SizedBox(width: 8),
                const Text("Invite to 282"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
