import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class ProfileAchievementsCard extends StatelessWidget {
  const ProfileAchievementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final achievementsState = context.watch<AchievementsState>();
    final achievements = achievementsState.achievements;
    final completedCount = achievements.where((a) => a.completed).length;
    final preview = achievements.take(8).toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(AchievementListScreen.route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _AchievementsHeader(
                completedCount: completedCount,
                total: achievements.length,
              ),
              const SizedBox(height: 12),
              _AchievementsGrid(achievements: preview),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementsHeader extends StatelessWidget {
  final int completedCount;
  final int total;

  const _AchievementsHeader({required this.completedCount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.starColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(PhosphorIconsRegular.trophy, color: context.colors.starColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Achievements',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: context.colors.textPrimary),
              ),
              Text(
                '$completedCount / $total earned',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: context.colors.textMuted, size: 20),
      ],
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;

  const _AchievementsGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) => _AchievementTile(achievement: achievements[index]),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.completed;
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? context.colors.accent.withValues(alpha: 0.1) : context.colors.border.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        PhosphorIconsRegular.trophy,
        size: 20,
        color: unlocked ? context.colors.accent : context.colors.textMuted.withValues(alpha: 0.4),
      ),
    );
  }
}
