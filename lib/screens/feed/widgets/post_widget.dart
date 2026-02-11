import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    if (post.includedMunroIds.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: PostHeader(
                post: post,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
            const SizedBox(height: 15),
            PostImagesCarousel(post: post),
            SizedBox(height: post.imageUrlsMap.isNotEmpty ? 20 : 0),
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostMunroList(post: post),
                  PostDescription(post: post),
                  PostTimings(post: post),
                  PostSocialRow(post: post, onLikeTap: onLikeTap)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
