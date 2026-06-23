import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/feed/widgets/empty_feed_header_image.dart';
import 'package:two_eight_two/screens/feed/widgets/empty_feed_icon_cluster.dart';
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
          const EmptyFeedHeaderImage(),
          const SizedBox(height: 20),
          const EmptyFeedIconCluster(),
          const SizedBox(height: 20),
          Text('Your friends haven\'t hit the hills yet!', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'When your pals start bagging munros, their adventures will show up here. Time to inspire them to get outside and make some memories!',
            style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
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
          SecondaryButton(
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
