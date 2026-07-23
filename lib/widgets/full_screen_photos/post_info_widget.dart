import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:two_eight_two/models/models.dart';
import 'dart:ui' as ui;

import 'package:two_eight_two/widgets/widgets.dart';

class PostInfoWidget extends StatelessWidget {
  final Post post;
  final bool expanded;
  final VoidCallback? onMoreTapped;
  const PostInfoWidget({
    super.key,
    required this.post,
    required this.expanded,
    this.onMoreTapped,
  });

  bool _textOverflows(String text, TextStyle style, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TappableUserName(userId: post.authorId, userName: post.authorDisplayName),
        const SizedBox(height: 4),
        Text(
          DateFormat('d MMM yyyy').format(post.completionDate ?? post.dateTimeCreated),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 4),
        LayoutBuilder(builder: (context, constraints) {
          final description = post.description ?? '';
          final style = const TextStyle(color: Colors.white, fontSize: 14);
          if (expanded) {
            return Text(description, style: style);
          }

          final overflows = _textOverflows(description, style, constraints.maxWidth);
          if (!overflows) return Text(description, style: style);
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Text(description, style: style, maxLines: 1, overflow: TextOverflow.clip),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Row(children: [
                  // fade gradient to mask the clipped text
                  Container(
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.transparent, Colors.black]),
                      )),
                  GestureDetector(
                    onTap: onMoreTapped,
                    child: Text(' more', style: style.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ]),
              ),
            ],
          );
        })
      ],
    );
  }
}
