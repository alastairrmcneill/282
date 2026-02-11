import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class PostSocialRow extends StatelessWidget {
  final Post post;
  final Future<void> Function() onLikeTap;

  const PostSocialRow({super.key, required this.post, required this.onLikeTap});

  @override
  Widget build(BuildContext context) {
    final commentsState = context.read<CommentsState>();
    final userLikeState = context.watch<UserLikeState>();
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onLikeTap();
          },
          child: Container(
            color: Colors.transparent,
            width: 24,
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: userLikeState.likedPosts.contains(post.uid)
                  ? const Icon(Icons.favorite, color: Colors.red, size: 18)
                  : const Icon(Icons.favorite_border, size: 18),
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: post.likes > 0
              ? Text(
                  post.likes.toString(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                )
              : null,
        ),
        GestureDetector(
          onTap: () {
            commentsState.reset();
            commentsState.setPostId = post.uid;
            commentsState.getPostComments();
            Navigator.of(context).pushNamed(CommentsScreen.route);
          },
          child: Container(
            color: Colors.transparent,
            width: 22,
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(FontAwesomeIcons.comment, size: 16),
            ),
          ),
        ),
        if (post.comments > 0)
          Text(
            post.comments.toString(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
      ],
    );
  }
}
