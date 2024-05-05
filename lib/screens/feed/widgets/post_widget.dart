import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/comments/screens/screens.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  const PostWidget({super.key, required this.post});

  Widget _buildIncludedMunroText() {
    if (post.includedMunros.isEmpty) return const SizedBox();
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        post.includedMunros.map((munro) => munro.name).join(', '),
        style: const TextStyle(
          fontSize: 12,
          height: 0.95,
          fontWeight: FontWeight.w200,
        ),
        maxLines: 2,
      ),
    );
  }

  Widget _buildDescription() {
    if (post.description == null || post.description == "") return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ExpandableText(text: post.description!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    CommentsState commentsState = Provider.of<CommentsState>(context, listen: false);
    UserLikeState userLikeState = Provider.of<UserLikeState>(context, listen: false);
    LikesState likesState = Provider.of<LikesState>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            PostHeader(post: post),
            post.imageUrlsMap.values.expand((element) => element).isEmpty
                ? const SizedBox()
                : PostImagesCarousel(post: post),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
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
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                          child: userLikeState.likedPosts.contains(post.uid!)
                              ? const Icon(FontAwesomeIcons.solidHeart, size: 22)
                              : const Icon(FontAwesomeIcons.heart, size: 22),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            likesState.reset();
                            likesState.setPostId = post.uid!;
                            LikeService.getPostLikes(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LikesScreen(),
                              ),
                            );
                          },
                          child: Text(post.likes == 1 ? "1 like" : "${post.likes} likes"),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            commentsState.reset();
                            commentsState.setPostId = post.uid!;
                            CommentsService.getPostComments(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CommentsScreen()));
                          },
                          child: const Icon(FontAwesomeIcons.comment, size: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
