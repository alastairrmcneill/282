import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ExpandablePhotoInfo extends StatefulWidget {
  final Post? currentPost;
  final bool expanded;
  final VoidCallback onMoreTapped;
  final VoidCallback onDismissed;
  const ExpandablePhotoInfo({
    super.key,
    required this.currentPost,
    required this.expanded,
    required this.onMoreTapped,
    required this.onDismissed,
  });

  @override
  State<ExpandablePhotoInfo> createState() => _ExpandablePhotoInfoState();
}

class _ExpandablePhotoInfoState extends State<ExpandablePhotoInfo> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.expanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDismissed,
              child: AnimatedOpacity(
                opacity: widget.expanded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(color: Colors.black12),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: widget.expanded
                    ? [Colors.black87, Colors.black54, Colors.transparent]
                    : [Colors.black87, Colors.transparent],
                stops: widget.expanded ? [0.0, 0.6, 1.0] : [0.0, 1.0],
              ),
            ),
            child: PostInfoWidget(
              post: widget.currentPost!,
              expanded: widget.expanded,
              onMoreTapped: widget.onMoreTapped,
            ),
          ),
        ),
      ],
    );
  }
}
