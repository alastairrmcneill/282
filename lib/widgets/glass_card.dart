import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool solidLightBackground;
  final bool solidDarkBackground;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.solidLightBackground = false,
    this.solidDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Padding(padding: padding, child: child);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: isDark
            ? (!solidDarkBackground ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0))
            : (!solidLightBackground
                ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0)),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? (solidDarkBackground ? Colors.white.withAlpha(25) : Colors.white.withAlpha(10))
                : (solidLightBackground ? Colors.white : const Color.fromRGBO(200, 200, 200, 0.1)),
            borderRadius: borderRadius,
            border: Border.all(
              color: isDark
                  ? AppColors.dark.border
                  : (solidLightBackground ? AppColors.light.border : Colors.white.withAlpha(50)),
              width: 0.7,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}
