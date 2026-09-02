import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class StravaScanningResultState extends StatelessWidget {
  final bool isError;
  final String title;
  final String subtitle;

  const StravaScanningResultState({
    super.key,
    required this.isError,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : context.colors.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.07)),
            child: Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.14)),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                    child: Icon(
                      isError ? PhosphorIconsBold.xCircle : PhosphorIconsBold.check,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: context.colors.textSubtitle),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
