import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PostHeader extends StatelessWidget {
  final Post post;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

  const PostHeader({
    super.key,
    required this.post,
    required this.onEdit,
    required this.onDelete,
  });

  void _showActionsDialog(BuildContext context) {
    final userState = context.read<UserState>();
    final isOwner = post.authorId == userState.currentUser?.uid;

    if (Platform.isIOS) {
      _showIOSActionSheet(context, isOwner);
    } else {
      _showAndroidBottomSheet(context, isOwner);
    }
  }

  void _showIOSActionSheet(BuildContext context, bool isOwner) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: isOwner
            ? [
                CupertinoActionSheetAction(
                  onPressed: () async {
                    await onEdit.call();
                  },
                  child: const Text('Edit'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () async {
                    await onDelete.call();
                  },
                  isDestructiveAction: true,
                  child: const Text('Delete'),
                ),
              ]
            : [
                CupertinoActionSheetAction(
                  onPressed: () {
                    final reportState = context.read<ReportState>();
                    reportState.setContentId = post.uid;
                    reportState.setType = "post";
                    Navigator.of(context).pushNamed(ReportScreen.route);
                  },
                  child: const Text('Report'),
                ),
              ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showAndroidBottomSheet(BuildContext context, bool isOwner) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isOwner
              ? [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit'),
                    onTap: () async {
                      await onEdit.call();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      await onDelete.call();
                    },
                  ),
                ]
              : [
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Report'),
                    onTap: () {
                      Navigator.pop(context);
                      final reportState = context.read<ReportState>();
                      reportState.setContentId = post.uid;
                      reportState.setType = "post";
                      Navigator.of(context).pushNamed(ReportScreen.route);
                    },
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: CircularProfilePicture(
                radius: 20,
                profilePictureURL: post.authorProfilePictureURL,
                profileUid: post.authorId,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ProfileScreen.route,
                      arguments: ProfileScreenArgs(userId: post.authorId),
                    );
                  },
                  child: Text(
                    post.authorDisplayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completed ${post.includedMunroIds.length == 1 ? "a munro" : "${post.includedMunroIds.length} munros"} • ${post.dateTimeCreated.timeAgoShort()}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: MyColors.mutedText),
                ),
                const SizedBox(height: 4),
                Text(
                  '${post.munroCountAtPostDateTime}/282 munros',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: MyColors.mutedText),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.more_vert, color: MyColors.mutedText),
            onPressed: () => _showActionsDialog(context),
          ),
        )
      ],
    );
  }
}
