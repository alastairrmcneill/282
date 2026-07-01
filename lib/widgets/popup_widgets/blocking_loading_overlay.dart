import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BlockingLoadingOverlay extends StatelessWidget {
  final String? text;
  const BlockingLoadingOverlay({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: ColoredBox(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LoadingAnimationWidget.dotsTriangle(
                  color: Colors.white,
                  size: 50,
                ),
                if (text != null && text!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    text!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
