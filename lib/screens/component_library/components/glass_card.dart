import 'dart:ui';

import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Padding(padding: padding, child: child);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color.fromRGBO(200, 200, 200, 0.1),
            borderRadius: borderRadius,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}
