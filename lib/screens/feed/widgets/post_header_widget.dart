import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PostHeader extends StatelessWidget {
  final Post post;
  const PostHeader({super.key, required this.post});

  Widget _buildPopUpMenu(
    BuildContext context, {
    required Post post,
    required UserState userState,
    required CreatePostState createPostState,
    required SettingsState settingsState,
  }) {
    List<MenuItem> menuItems = [];
    if (post.authorId == userState.currentUser?.uid) {
      menuItems = [
        MenuItem(
          text: 'Edit',
          onTap: () {
            createPostState.reset();
            createPostState.loadPost = post;
            createPostState.setPostPrivacy = settingsState.defaultPostVisibility;
            Navigator.of(context).pushNamed(CreatePostScreen.route);
          },
        ),
        MenuItem(
          text: 'Delete',
          onTap: () {
            PostService.deletePost(context, post: post);
          },
        ),
      ];
    } else {
      ReportState reportState = Provider.of<ReportState>(context, listen: false);
      menuItems = [
        MenuItem(
          text: 'Report',
          onTap: () {
            reportState.setContentId = post.uid ?? "";
            reportState.setType = "post";
            Navigator.of(context).pushNamed(ReportScreen.route);
          },
        ),
      ];
    }
    return PopupMenuBase(items: menuItems);
  }

  @override
  Widget build(BuildContext context) {
    CreatePostState createPostState = Provider.of<CreatePostState>(context, listen: false);
    SettingsState settingsState = Provider.of<SettingsState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProfilePicture(
                radius: 18,
                profilePictureURL: post.authorProfilePictureURL,
                profileUid: post.authorId,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      ProfileService.loadUserFromUid(context, userId: post.authorId);
                      Navigator.of(context).pushNamed(ProfileScreen.route);
                    },
                    child: Text(
                      post.authorDisplayName ?? "",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    post.dateTimeCreated.timeAgoLong(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          _buildPopUpMenu(
            context,
            userState: userState,
            createPostState: createPostState,
            settingsState: settingsState,
            post: post,
          ),
        ],
      ),
    );
  }
}
