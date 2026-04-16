import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';

class PillButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final double height;
  final String? analyticsEvent;
  final Map<String, dynamic>? analyticsProperties;

  const PillButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.height = 48,
    this.analyticsEvent,
    this.analyticsProperties,
  });

  @override
  Widget build(BuildContext context) {
    final analytics = context.read<Analytics>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0x1A10B981) // emerald-500/10
        : const Color(0xFFECFDF5); // emerald-50
    final textColor = isDark
        ? const Color(0xFF34D399) // emerald-400
        : const Color(0xFF047857); // emerald-700
    final borderColor = isDark
        ? const Color(0x3310B981) // emerald-500/20
        : const Color(0xFFA7F3D0); // emerald-200

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onPressed == null
            ? null
            : () {
                onPressed!();
                if (analyticsEvent != null) {
                  analytics.track(analyticsEvent!, props: analyticsProperties);
                }
              },
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme(
                data: IconThemeData(color: textColor, size: 18),
                child: icon,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(color: textColor, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
