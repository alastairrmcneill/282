import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class PaginationLoader extends StatelessWidget {
  const PaginationLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: LoadingAnimationWidget.dotsTriangle(
          color: context.colors.accent,
          size: 30,
        ),
      ),
    );
  }
}
