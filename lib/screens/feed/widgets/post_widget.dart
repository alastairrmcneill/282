import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/comments/screens/screens.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PostWidget extends StatelessWidget {
  final Post post;
  final bool inFeed;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;
  final Future<void> Function() onLikeTap;

  const PostWidget({
    super.key,
    required this.post,
    this.inFeed = true,
    required this.onEdit,
    required this.onDelete,
    required this.onLikeTap,
  });

  Widget _buildIncludedMunroText(BuildContext context) {
    final munroState = context.read<MunroState>();
    if (post.includedMunroIds.isEmpty) return const SizedBox();
    return Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          children: [
            for (int i = 0; i < post.includedMunroIds.length; i++) ...[
              GestureDetector(
                onTap: () {
                  var munro = munroState.munroList.firstWhere(
                    (m) => m.id == post.includedMunroIds[i],
                    orElse: () => Munro.empty,
                  );
                  Navigator.of(context).pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: munro));
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
    final commentsState = context.read<CommentsState>();
    final userLikeState = context.watch<UserLikeState>();

    if (post.includedMunroIds.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        color: MyColors.backgroundColor,
        child: Column(
          children: [
            PostHeader(
              post: post,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
            PostImagesCarousel(post: post),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  _buildIncludedMunroText(context),
                  _buildDescription(context),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: onLikeTap,
                          child: userLikeState.likedPosts.contains(post.uid)
                              ? const Icon(CupertinoIcons.heart_fill)
                              : const Icon(CupertinoIcons.heart),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              LikesScreen.route,
                              arguments: LikesScreenArgs(postId: post.uid),
                            );
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
                            commentsState.getPostComments();
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
