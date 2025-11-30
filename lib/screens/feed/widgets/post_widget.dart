import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/comments/screens/screens.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final bool inFeed;
  const PostWidget({super.key, required this.post, this.inFeed = true});

  Widget _buildIncludedMunroText(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    if (post.includedMunroIds.isEmpty) return const SizedBox();
    return Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          children: [
            for (int i = 0; i < post.includedMunroIds.length; i++) ...[
              GestureDetector(
                onTap: () {
                  // Handle the click event for each munro.name here
                  munroState.setSelectedMunro = munroState.munroList.firstWhere(
                    (m) => m.id == post.includedMunroIds[i],
                    orElse: () => Munro.empty,
                  );
                  MunroPictureService.getMunroPictures(context, munroId: post.includedMunroIds[i], count: 4);
                  ReviewService.getMunroReviews(context);
                  Navigator.of(context).pushNamed(MunroScreen.route);
                },
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: munroState.munroList
                            .firstWhere(
                              (m) => m.id == post.includedMunroIds[i],
                              orElse: () => Munro.empty,
                            )
                            .name,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(height: 1.2),
                      ),
                      if (i < post.includedMunroIds.length - 1)
                        TextSpan(
                          text: ', ',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(height: 1.2),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ));
  }

  Widget _buildDescription(BuildContext context) {
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
    UserLikeState userLikeState = Provider.of<UserLikeState>(context);
    LikesState likesState = Provider.of<LikesState>(context);

    if (post.includedMunroIds.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        color: MyColors.backgroundColor,
        child: Column(
          children: [
            PostHeader(post: post),
            PostImagesCarousel(post: post),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  // Align(
                  //   alignment: Alignment.centerLeft,
                  //   child: Text(
                  //     post.title,
                  //     maxLines: 2,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: Theme.of(context).textTheme.titleLarge,
                  //   ),
                  // ),
                  _buildIncludedMunroText(context),
                  _buildDescription(context),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (userLikeState.likedPosts.contains(post.uid)) {
                              LikeService.unLikePost(context, post: post, inFeed: inFeed);
                            } else {
                              LikeService.likePost(context, post: post, inFeed: inFeed);
                            }
                          },
                          child: userLikeState.likedPosts.contains(post.uid)
                              ? const Icon(CupertinoIcons.heart_fill)
                              : const Icon(CupertinoIcons.heart),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            likesState.reset();
                            likesState.setPostId = post.uid;
                            LikeService.getPostLikes(context);
                            Navigator.of(context).pushNamed(LikesScreen.route);
                          },
                          child: Text(
                            post.likes == 1 ? "1 like" : "${post.likes} likes",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            commentsState.reset();
                            commentsState.setPostId = post.uid;
                            commentsState.getPostComments(context);
                            Navigator.of(context).pushNamed(CommentsScreen.route);
                          },
                          child: const Icon(CupertinoIcons.chat_bubble, size: 22),
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
