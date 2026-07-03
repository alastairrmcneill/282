import 'package:flutter/material.dart';

class BottomButtonBar extends StatelessWidget {
  final Widget child;

  const BottomButtonBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: child,
      ),
    );
  }
}
