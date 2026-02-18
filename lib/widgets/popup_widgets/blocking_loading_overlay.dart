import 'package:flutter/material.dart';

class BlockingLoadingOverlay extends StatelessWidget {
  const BlockingLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: ColoredBox(
          color: Colors.black45, // adjust opacity to taste
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
