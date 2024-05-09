import 'package:flutter/cupertino.dart';
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
  }) {
    if (post.authorId == userState.currentUser?.uid) {
      return PopupMenuButton(
        icon: const Icon(CupertinoIcons.ellipsis_vertical),
        onSelected: (value) async {
          if (value == MenuItems.item1) {
            createPostState.reset();
            createPostState.loadPost = post;
            Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePostScreen()));
          } else if (value == MenuItems.item2) {
            PostService.deletePost(context, post: post);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: MenuItems.item1,
            child: Text('Edit'),
          ),
          PopupMenuItem(
            value: MenuItems.item2,
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
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.authorDisplayName,
                    style: Theme.of(context).textTheme.titleMedium,
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
