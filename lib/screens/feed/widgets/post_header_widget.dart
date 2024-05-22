import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  }) {
    if (post.authorId == userState.currentUser?.uid) {
      List<MenuItem> menuItems = [
        MenuItem(
          text: 'Edit',
          onTap: () {
            createPostState.reset();
            createPostState.loadPost = post;
            Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePostScreen()));
          },
        ),
        MenuItem(
          text: 'Delete',
          onTap: () {
            PostService.deletePost(context, post: post);
          },
        ),
      ];
      return PopupMenuBase(items: menuItems);
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    CreatePostState createPostState = Provider.of<CreatePostState>(context, listen: false);
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Text(
                      post.authorDisplayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    post.dateTime.timeAgoLong(),
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
            post: post,
          ),
        ],
      ),
    );
  }
}
