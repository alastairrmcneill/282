import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

// Reusable Munro Card Component
class TestMunroCard extends StatelessWidget {
  final Munro munro;
  final bool isSelected;
  final bool isMain;
  final VoidCallback? onTap;

  const TestMunroCard({
    super.key,
    required this.munro,
    this.isSelected = false,
    this.isMain = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Color backgroundColor =
        isSelected || isMain ? colors.accent.withValues(alpha: 0.12) : colors.surface;
    Color borderColor = isMain
        ? colors.accent.withValues(alpha: 0.4)
        : isSelected
            ? colors.accent.withValues(alpha: 0.6)
            : colors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Row(
          children: [
            if (isMain)
              Icon(
                Icons.check_circle,
                size: 20,
                color: colors.accent,
              )
            else
              Icon(
                isSelected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 20,
                color: isSelected ? colors.accent : colors.textMuted,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    munro.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    "${munro.area} - ${munro.meters}m",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Section Header Component
class SectionHeader extends StatelessWidget {
  final String text;

  const SectionHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: context.colors.textPrimary,
      ),
    );
  }
}

class SelectMunrosScreenArgs {
  final Munro mainMunro;

  SelectMunrosScreenArgs({required this.mainMunro});
}

class SelectMunrosScreen extends StatefulWidget {
  const SelectMunrosScreen({super.key, required this.mainMunro});
  final Munro mainMunro;
  static const String route = '/posts/select-munros';

  @override
  State<SelectMunrosScreen> createState() => _SelectMunrosScreenState();
}

class _SelectMunrosScreenState extends State<SelectMunrosScreen> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    final createPostState = context.watch<CreatePostState>();

    List<Munro> commonlyClimbedWith = munroState.munroList
        .where((munro) => widget.mainMunro.commonlyClimbedWith
            .map((e) => e.climbedWithId)
            .contains(munro.id))
        .toList();

    List<Munro> otherMunros = munroState.munroList
        .where((munro) =>
            munro.id != widget.mainMunro.id &&
            !commonlyClimbedWith.map((e) => e.id).contains(munro.id))
        .toList();

    var selectedMunroIds = createPostState.selectedMunroIds;

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Climbed Together?',
          style: textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select any munros you climbed with ${widget.mainMunro.name}',
              style: textTheme.titleSmall
                  ?.copyWith(color: context.colors.textSubtitle),
            ),
            const SizedBox(height: 16),

            // Main Munro Card
            TestMunroCard(
              munro: widget.mainMunro,
              isMain: true,
            ),
            const SizedBox(height: 24),

            // Often Climbed Together Section
            if (commonlyClimbedWith.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SectionHeader(text: 'Often Climbed Together'),
              ),
              ...commonlyClimbedWith.map((munro) {
                bool selected = selectedMunroIds.contains(munro.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TestMunroCard(
                    munro: munro,
                    isSelected: selected,
                    onTap: () {
                      if (selected) {
                        createPostState.removeMunro(munro.id);
                      } else {
                        createPostState.addMunro(munro.id);
                      }
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // Other Munros Section
            if (_expanded) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SectionHeader(text: 'Other Munros'),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = false),
                      child: Text(
                        'Hide',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...otherMunros.map((munro) {
                bool selected = selectedMunroIds.contains(munro.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TestMunroCard(
                    munro: munro,
                    isSelected: selected,
                    onTap: () {
                      if (selected) {
                        createPostState.removeMunro(munro.id);
                      } else {
                        createPostState.addMunro(munro.id);
                      }
                    },
                  ),
                );
              }),
            ] else
              InkWell(
                onTap: () => setState(() => _expanded = true),
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    border: Border.all(color: context.colors.border, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Other Munros',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: context.colors.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.background,
          border: Border(
            top: BorderSide(color: context.colors.divider, width: 1),
          ),
        ),
        child: BottomButtonBar(
          child: SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () {
                context
                    .read<Analytics>()
                    .track(AnalyticsEvent.selectCommonlyClimbedMunros, props: {
                  AnalyticsProp.munroId: widget.mainMunro.id,
                  AnalyticsProp.commonlyClimbedWithCount:
                      commonlyClimbedWith.length,
                  AnalyticsProp.selectedMunroCount:
                      createPostState.selectedMunroIds.length,
                });
                Navigator.of(context).pushNamed(CreatePostScreen.route);
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
