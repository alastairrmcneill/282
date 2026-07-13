import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/achievements/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class AchievementListScreen extends StatelessWidget {
  const AchievementListScreen({super.key});
  static const String route = '/achievements_list';

  static const _categoryOrder = [
    AchievementTypes.totalCount,
    AchievementTypes.multiMunroDay,
    AchievementTypes.areaGoal,
    AchievementTypes.highestMunros,
    AchievementTypes.lowestMunros,
    AchievementTypes.monthlyMunro,
    AchievementTypes.nameGoal,
  ];

  @override
  Widget build(BuildContext context) {
    final achievements = context
        .watch<AchievementsState>()
        .achievements
        .where((a) => a.type != AchievementTypes.annualGoal)
        .toList();
    final unlocked = achievements.where((a) => a.completed).length;

    final grouped = <String, List<Achievement>>{};
    for (final type in _categoryOrder) {
      final items = achievements.where((a) => a.type == type).toList()
        ..sort((a, b) => a.achievementId.compareTo(b.achievementId));
      if (items.isNotEmpty) grouped[type] = items;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            '$unlocked / ${achievements.length} unlocked',
            style: textTheme.bodySmall?.copyWith(color: context.colors.accent),
          ),
          const SizedBox(height: 24),
          ...grouped.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: AchievementCategorySection(
                type: entry.key,
                achievements: entry.value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
