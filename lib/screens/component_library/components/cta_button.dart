import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';

class CtaButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool? disabled;
  final double? width;
  final double? height;
  final String? analyticsEvent;
  final Map<String, dynamic>? analyticsProperties;

  const CtaButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.analyticsEvent,
    this.analyticsProperties,
    this.width = double.infinity,
    this.height = 48,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final analytics = context.read<Analytics>();
    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: disabled == true
            ? null
            : () {
                onPressed!();
                if (analyticsEvent != null) {
                  analytics.track(analyticsEvent!, props: analyticsProperties);
                }
              },
        child: child,
      ),
    );
  }
}
