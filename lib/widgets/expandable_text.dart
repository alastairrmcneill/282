import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class ExpandableText extends StatelessWidget {
  final String text;
  const ExpandableText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      text,
      trimMode: TrimMode.Length,
      trimLines: 3,
      trimLength: 160,
      colorClickableText: Colors.black45,
      trimCollapsedText: ' more',
      trimExpandedText: ' ...less',
    );
  }
}
