import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class GroupFilterInfoView extends StatelessWidget {
  const GroupFilterInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Plan Your Next Adventure",
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Select friends to plan a trip with and discover munros that none of you have completed yet",
            style: textTheme.bodyMedium?.copyWith(color: colors.textSubtitle),
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
        ],
      ),
    );
  }
}
