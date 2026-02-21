import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class NotificationTile extends StatelessWidget {
  final Notif notification;
  const NotificationTile({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final commentsState = context.watch<CommentsState>();
    final notificationsState = context.read<NotificationsState>();
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        notification.read = true;
        notificationsState.markNotificationAsRead(notification);
        if (notification.type == "like" || notification.type == "comment") {
          // Navigate to the comments page of the post
          // Load in post
          commentsState.reset();
          // TODO: Get post here too and set it as selected post
          commentsState.setPostId = notification.postId!;
          commentsState.getPostComments();
          Navigator.of(context).pushNamed(CommentsScreen.route);
        } else if (notification.type == "follow") {
          // Navigate to the user post
          Navigator.of(context).pushNamed(
            ProfileScreen.route,
            arguments: ProfileScreenArgs(userId: notification.sourceId),
          );
        }
      },
      child: Container(
        color: notification.read ? Colors.transparent : Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  color: notification.read ? Colors.transparent : MyColors.notificationDotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              CircularProfilePicture(
                radius: 18,
                profilePictureURL: notification.sourceProfilePictureURL,
                profileUid: notification.sourceId,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Opacity(
                  opacity: notification.read ? 0.6 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        softWrap: true,
                        text: TextSpan(
                          text: notification.sourceDisplayName,
                          style: textTheme.titleMedium,
                          children: [
                            TextSpan(
                              text: " ${notification.detail}",
                              style: textTheme.bodyMedium?.copyWith(fontSize: 16, color: MyColors.subtitleColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.dateTime.timeAgoShort(),
                        style: textTheme.bodySmall?.copyWith(color: MyColors.subtitleColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
