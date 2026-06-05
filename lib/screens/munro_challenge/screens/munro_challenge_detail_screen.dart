import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro_challenge/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/munro_completed_tile.dart';

class MunroChallengeDetailScreen extends StatelessWidget {
  const MunroChallengeDetailScreen({super.key});
  static const String route = '/munro_challenge/detail';

  int _monthStreak(List<MunroCompletion> completions) {
    final now = DateTime.now();
    int streak = 0;
    for (int m = now.month; m >= 1; m--) {
      final hasCompletion = completions.any(
        (c) => c.dateTimeCompleted.year == now.year && c.dateTimeCompleted.month == m,
      );
      if (hasCompletion) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
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
              '$completedCount of $goal munros',
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
      body: ListView(
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
