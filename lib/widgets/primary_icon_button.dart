import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';

class PrimaryIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final double size;
  final String? analyticsEvent;
  final Map<String, dynamic>? analyticsProperties;

  const PrimaryIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 48,
    this.analyticsEvent,
    this.analyticsProperties,
  });

  @override
  Widget build(BuildContext context) {
    final analytics = context.read<Analytics>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void handleTap() {
      onPressed?.call();
      if (analyticsEvent != null) {
        analytics.track(analyticsEvent!, props: analyticsProperties);
      }
    }

    if (isDark) {
      return ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.white.withValues(alpha: 0.1),
            shape: CircleBorder(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed == null ? null : handleTap,
              child: SizedBox(
                width: size,
                height: size,
                child: Center(child: icon),
              ),
            ),
          ),
        ),
      );
    } else {
      return Material(
        color: const Color(0xFFF3F4F6), // gray-100
        shape: const CircleBorder(
          side: BorderSide(color: Color(0xFFE5E7EB), width: 1), // gray-200
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed == null ? null : handleTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(child: icon),
          ),
        ),
      );
    }
  }
}
