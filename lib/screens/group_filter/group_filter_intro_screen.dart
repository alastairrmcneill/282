import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/group_filter/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class GroupFilterIntroScreen extends StatelessWidget {
  static const String route = '${ExploreTab.route}/group_planning';

  const GroupFilterIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CustomAppBarBackButton(onPressed: () => Navigator.pop(context)),
        title: const Text("Group Planning"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _GroupPlanningIntroContent(),
              ),
            ),
            _GetStartedButton(),
          ],
        ),
      ),
    );
  }
}

class _GroupPlanningIntroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        _HeroIcon(),
        const SizedBox(height: 24),
        Text(
          "Plan Your Next Adventure",
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Select friends to plan a trip with and discover munros that none of you have completed yet",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: context.colors.textSubtitle,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
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
    );
  }
}

class _HeroIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: context.colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.accent.withValues(alpha: 0.2),
          width: 0.65,
        ),
      ),
      child: Icon(
        PhosphorIconsRegular.usersThree,
        color: context.colors.accent,
        size: 44,
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed(GroupFilterScreen.route),
            child: Text(
              "Get Started",
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
