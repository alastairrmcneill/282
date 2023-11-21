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
        icon: Icon(Icons.more_vert_rounded),
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
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircularProfilePicture(
          radius: 20,
          profilePictureURL: comment.authorProfilePictureURL,
        ),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(comment.authorDisplayName),
                  Text(comment.dateTime.timeAgoShort()),
                ],
              ),
              Text(comment.commentText),
            ],
          ),
        ),
        _buildPopUpMenu(context, comment: comment, userState: userState)
      ],
    );
  }
}
