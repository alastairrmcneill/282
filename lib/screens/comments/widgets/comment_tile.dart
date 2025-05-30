import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

import '../../screens.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  Widget _buildPopUpMenu(
    BuildContext context, {
    required Comment comment,
    required UserState userState,
  }) {
    List<MenuItem> menuItems = [];
    if (comment.authorId == userState.currentUser?.uid) {
      menuItems = [
        MenuItem(
          text: 'Delete',
          onTap: () {
            CommentsService.deleteComment(context, comment: comment);
          },
        ),
      ];
    } else {
      ReportState reportState = Provider.of<ReportState>(context, listen: false);
      menuItems = [
        MenuItem(
          text: 'Report',
          onTap: () {
            reportState.setContentId = '${comment.postId}/${comment.uid ?? ""}';
            reportState.setType = "comment";
            Navigator.of(context).pushNamed(ReportScreen.route);
          },
        ),
      ];
    }
    return PopupMenuBase(items: menuItems);
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
                    ProfileService.loadUserFromUid(context, userId: comment.authorId);
                    Navigator.of(context).pushNamed(
                      ProfileScreen.route,
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
          _buildPopUpMenu(context, comment: comment, userState: userState)
        ],
      ),
    );
  }
}
