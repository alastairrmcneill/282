import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  final String? text;
  final double size;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.text = 'Loading...',
    this.size = 128,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final animColor = color ?? Theme.of(context).primaryColor;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.dotsTriangle(
            color: animColor,
            size: size,
          ),
          if (text != null && text!.isNotEmpty) ...[
            const SizedBox(height: 16),
            DefaultTextStyle.merge(
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              child: Text(text!),
            ),
          ],
        ],
      ),
    );
  }
}
