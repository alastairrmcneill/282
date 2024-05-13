import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/comments/state/comments_state.dart';
import 'package:two_eight_two/screens/profile/screens/screens.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class NotificationTile extends StatelessWidget {
  final Notif notification;
  const NotificationTile({super.key, required this.notification});

  Widget _buildText(Notif notification) {
    String notificationText = '';
    if (notification.type == "like") {
      notificationText = " liked your post.  ";
    } else if (notification.type == "comment") {
      notificationText = " commented on your post.  ";
    } else if (notification.type == "follow") {
      notificationText = " followed you.  ";
    }
    return RichText(
      text: TextSpan(
        text: notification.sourceDisplayName,
        style: const TextStyle(
          fontFamily: "NotoSans",
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: notificationText,
            style: const TextStyle(
              fontFamily: "NotoSans",
              fontWeight: FontWeight.normal,
            ),
          ),
          TextSpan(
            text: notification.dateTime.timeAgoShort(),
            style: const TextStyle(
              fontFamily: "NotoSans",
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    CommentsState commentsState = Provider.of<CommentsState>(context);
    return ListTile(
      tileColor: !notification.read ? Colors.transparent : Colors.green.withOpacity(0.05),
      leading: CircularProfilePicture(
        radius: 15,
        profilePictureURL: notification.sourceProfilePictureURL,
      ),
      title: _buildText(notification),
      onTap: () {
        notification.read = true;
        NotificationsService.markNotificationAsRead(context, notification: notification);
        if (notification.type == "like" || notification.type == "comment") {
          // Navigate to the comments page of the post
          // Load in post
          commentsState.reset();
          commentsState.setPostId = notification.postId!;
          CommentsService.getPostComments(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CommentsScreen()));
        } else if (notification.type == "follow") {
          // Navigate to the user post
          ProfileService.loadUserFromUid(context, userId: notification.sourceId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            ),
          );
        }
      },
    );
  }
}
