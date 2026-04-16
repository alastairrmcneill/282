import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

import '../../screens.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  void _showActionsDialog(BuildContext context) {
    final userState = context.read<UserState>();
    final commentsState = context.read<CommentsState>();

    final isOwner = comment.authorId == userState.currentUser?.uid;

    final items = isOwner
        ? [
            ActionMenuItems(
              title: 'Delete',
              isDestructive: true,
              onPressed: () async {
                await commentsState.deleteComment(comment: comment);
              },
            ),
          ]
        : [
            ActionMenuItems(
              title: 'Report',
              onPressed: () {
                final reportState = context.read<ReportState>();
                reportState.setContentId = '${comment.postId}/${comment.uid ?? ""}';
                reportState.setType = "comment";
                Navigator.of(context).pushNamed(ReportScreen.route);
              },
            ),
          ];
    showActionSheet(context, items);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircularProfilePicture(
            radius: 15,
            profilePictureURL: comment.authorProfilePictureURL,
            profileUid: comment.authorId,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      ProfileScreen.route,
                      arguments: ProfileScreenArgs(userId: comment.authorId),
                    );
                  },
                  child: Text(
                    "${comment.authorDisplayName} - ${comment.dateTime.timeAgoShort()}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.2),
                  ),
                ),
                Text(
                  comment.commentText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              padding: EdgeInsets.all(0),
              icon: Icon(
                PhosphorIconsBold.dotsThreeVertical,
                color: context.colors.textMuted,
              ),
              onPressed: () => _showActionsDialog(context),
            ),
          )
        ],
      ),
    );
  }
}
