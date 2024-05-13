import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  Widget _buildPopUpMenu(
    BuildContext context, {
    required Comment comment,
    required UserState userState,
  }) {
    if (comment.authorId == userState.currentUser?.uid) {
      return PopupMenuButton(
        icon: Icon(CupertinoIcons.ellipsis_vertical),
        onSelected: (value) async {
          if (value == MenuItems.item1) {
            // Delete
            CommentsService.deleteComment(context, comment: comment);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: MenuItems.item1,
            child: Text('Delete'),
          ),
        ],
      );
    } else {
      return const SizedBox(width: 48);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircularProfilePicture(
            radius: 20,
            profilePictureURL: comment.authorProfilePictureURL,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${comment.authorDisplayName} - ${comment.dateTime.timeAgoShort()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(height: 10),
                Text(comment.commentText),
              ],
            ),
          ),
          _buildPopUpMenu(context, comment: comment, userState: userState)
        ],
      ),
    );
  }
}
