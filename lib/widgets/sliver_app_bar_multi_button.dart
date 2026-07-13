import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/support/theme.dart';

class SliverAppBarButtonItem {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? analyticsEvent;
  final Map<String, dynamic>? analyticsProperties;

  const SliverAppBarButtonItem({
    required this.icon,
    this.onPressed,
    this.analyticsEvent,
    this.analyticsProperties,
  });
}

class SliverAppBarMultiButton extends StatelessWidget {
  final List<SliverAppBarButtonItem> buttons;
  final double spacing;
  final EdgeInsets padding;

  const SliverAppBarMultiButton({
    super.key,
    required this.buttons,
    this.spacing = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    final analytics = context.read<Analytics>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Material(
          color: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: 40,
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: spacing,
                children: buttons.map((button) {
                  return InkWell(
                    customBorder: const CircleBorder(),
                    onTap: button.onPressed == null
                        ? null
                        : () {
                            button.onPressed?.call();
                            if (button.analyticsEvent != null) {
                              analytics.track(
                                button.analyticsEvent!,
                                props: button.analyticsProperties,
                              );
                            }
                          },
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: Center(
                        child: IconTheme(
                          data: IconThemeData(
                            color: AppColors.light.surface,
                            size: 20,
                          ),
                          child: button.icon,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
