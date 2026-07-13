import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class AgeRestrictedView extends StatelessWidget {
  const AgeRestrictedView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.shieldWarning,
              size: 48,
              color: context.colors.accent,
            ),
          ),
          const SizedBox(height: 20),
          Text('You need to be 13 or over', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            "282 shares photos and posts from other users throughout the app, so it's only available to baggers aged 13 and up.",
            style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
