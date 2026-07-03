import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class GroupFilterIntroDialog extends StatelessWidget {
  const GroupFilterIntroDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeroIcon(),
            const SizedBox(height: 24),
            Text(
              "Plan Your Next Adventure",
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Select friends to plan a trip with and discover munros that none of you have completed yet",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.colors.textSubtitle,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FeatureHighlightCard(
              icon: PhosphorIconsRegular.usersThree,
              title: "Choose Your Group",
              description: "Select friends who are joining you on this adventure",
            ),
            const SizedBox(height: 12),
            FeatureHighlightCard(
              icon: PhosphorIconsRegular.mountains,
              title: "Discover New Munros",
              description: "See munros that none of your group has completed",
            ),
            const SizedBox(height: 12),
            FeatureHighlightCard(
              icon: PhosphorIconsRegular.mapTrifold,
              title: "View on Map",
              description: "Explore available munros on the interactive map",
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Got it"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: context.colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.accent.withValues(alpha: 0.2),
          width: 0.65,
        ),
      ),
      child: Icon(
        PhosphorIconsRegular.usersThree,
        color: context.colors.accent,
        size: 36,
      ),
    );
  }
}
