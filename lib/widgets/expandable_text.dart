import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:two_eight_two/extensions/extensions.dart';

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
      style: TextStyle(color: context.colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w300, height: 1.5),
    );
  }
}
