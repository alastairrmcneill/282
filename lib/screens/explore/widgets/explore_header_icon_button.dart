import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class ExploreHeaderIconButton extends StatelessWidget {
  const ExploreHeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Stack(
        children: [
          SizedBox(
            height: 44,
            width: 44,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.surface,
                  shape: const CircleBorder(),
                  elevation: 0,
                  padding: const EdgeInsets.all(13),
                  side: BorderSide(
                    color: context.colors.accent,
                    width: 0.5,
                  ),
                ),
                onPressed: onPressed,
                child: Icon(
                  icon,
                  color: context.colors.accent,
                  size: 20,
                ),
              ),
            ),
          ),
          if (showBadge)
            Positioned(
              right: 7,
              top: 7,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: context.colors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
