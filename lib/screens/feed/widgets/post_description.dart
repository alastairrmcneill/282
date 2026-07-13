import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class PostDescription extends StatelessWidget {
  final Post post;
  const PostDescription({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.description == null || post.description!.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(post.description!, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
