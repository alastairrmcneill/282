import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class CheckMarkWidget extends StatelessWidget {
  const CheckMarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.accent.withValues(alpha: 0.07),
      ),
      child: Center(
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.accent.withValues(alpha: 0.14),
          ),
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.accent,
              ),
              child: const Icon(PhosphorIconsBold.check, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
