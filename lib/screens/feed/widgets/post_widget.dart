import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  const PostWidget({super.key, required this.post});

  Widget _buildIncludedMunroText() {
    if (post.includedMunros.isEmpty) {
      return const SizedBox();
    } else if (post.includedMunros.length == 1) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          post.includedMunros[0].name,
          style: const TextStyle(
            fontSize: 12,
            height: 0.95,
            fontWeight: FontWeight.w200,
          ),
        ),
      );
    } else {
      String text = "";
      int len = post.includedMunros.length - 1;
      text = "${post.includedMunros[0].name} + $len more.";
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            height: 0.95,
            fontWeight: FontWeight.w200,
          ),
        ),
      );
    }
  }

  Widget _buildDescription() {
    if (post.description == null || post.description == "") return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          post.description!,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildPopUpMenu(
    BuildContext context, {
    required Post post,
    required UserState userState,
    required CreatePostState createPostState,
  }) {
    if (post.authorId == userState.currentUser?.uid) {
      return PopupMenuButton(
        icon: const Icon(Icons.more_vert_rounded),
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
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    UserState userState = Provider.of<UserState>(context);
    CommentsState commentsState = Provider.of<CommentsState>(context);
    UserLikeState userLikeState = Provider.of<UserLikeState>(context);

    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProfilePicture(
                    radius: 25,
                    profilePictureURL: post.authorProfilePictureURL,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorDisplayName),
                      Text(
                        post.dateTime.timeAgoLong(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 12,
                        ),
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
          post.imageURLs.isEmpty ? const SizedBox() : PostImagesCarousel(post: post),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              post.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          _buildIncludedMunroText(),
          _buildDescription(),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (userLikeState.likedPosts.contains(post.uid!)) {
                      LikeService.unLikePost(context, post: post);
                    } else {
                      LikeService.likePost(context, post: post);
                    }
                  },
                  child: Row(
                    children: [
                      userLikeState.likedPosts.contains(post.uid!)
                          ? const Icon(Icons.favorite_rounded)
                          : const Icon(Icons.favorite_outline_rounded),
                      const SizedBox(width: 10),
                      Text(post.likes == 0
                          ? "Like"
                          : post.likes == 1
                              ? "1 like"
                              : "${post.likes} likes"),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    commentsState.reset();
                    commentsState.setPostId = post.uid!;
                    CommentsService.getPostComments(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CommentsScreen()));
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.comment_outlined),
                      SizedBox(width: 10),
                      Text("Comment"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 0.2,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
