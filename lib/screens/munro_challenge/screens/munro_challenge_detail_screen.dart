import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/munro_challenge/screens/create_munro_challenge_screen.dart';
import 'package:two_eight_two/screens/munro_challenge/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroChallengeDetailScreen extends StatelessWidget {
  const MunroChallengeDetailScreen({super.key});
  static const String route = '/munro_challenge/detail';

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsRegular.trophy, size: 64, color: context.colors.textMuted),
            const SizedBox(height: 24),
            Text(
              'No challenge set for ${DateTime.now().year}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Set a target and track how many Munros you can bag this year.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              onPressed: () => Navigator.of(context).pushNamed(CreateMunroChallengeScreen.route),
              child: const Text('Set My Target'),
            ),
          ],
        ),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    final achievementsState = context.watch<AchievementsState>();
    final munroCompletionState = context.watch<MunroCompletionState>();
    final munroState = context.watch<MunroState>();

    final achievement = achievementsState.currentAchievement!;
    final goal = achievement.annualTarget ?? 0;

    final yearCompletions = munroCompletionState.munroCompletions
        .where((mc) => mc.dateTimeCompleted.year == DateTime.now().year)
        .toList()
      ..sort((a, b) => b.dateTimeCompleted.compareTo(a.dateTimeCompleted));

    final completedCount = yearCompletions.length;

    final completedMunros = munroState.munroList.where((m) => yearCompletions.any((mc) => mc.munroId == m.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${DateTime.now().year} Annual Challenge'),
            Text(
              goal == 0 ? 'No goal set' : '$completedCount of $goal munros',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
            ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.caretLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: goal == 0
          ? _buildEmptyState(context)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ChallengeDetailHeroCard(completed: completedCount, goal: goal),
                const SizedBox(height: 24),
                CompletedThisYearSection(
                  completions: yearCompletions,
                  munros: completedMunros,
                  completedCount: completedCount,
                ),
              ],
            ),
    );
  }
}
