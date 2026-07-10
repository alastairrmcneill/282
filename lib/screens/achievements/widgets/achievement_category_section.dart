import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'achievement_badge_tile.dart';
import 'achievement_type_icon.dart';

class AchievementCategorySection extends StatelessWidget {
  final String type;
  final List<Achievement> achievements;

  const AchievementCategorySection({
    super.key,
    required this.type,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = achievementCategoryLabel(type);
    final unlocked = achievements.where((a) => a.completed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$unlocked/${achievements.length}',
              style: TextStyle(fontSize: 11, color: colors.middleGrey),
            ),
            const SizedBox(width: 8),
            Expanded(child: Divider(color: colors.divider, thickness: 1, height: 1)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.68,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return AchievementBadgeTile(
              achievement: achievement,
              onTap: () {
                context.read<Analytics>().track(
                  AnalyticsEvent.achievementTapped,
                  props: {
                    AnalyticsProp.achievementId: achievement.achievementId,
                    AnalyticsProp.achievementName: achievement.name,
                    AnalyticsProp.status: achievement.completed ? 'unlocked' : 'locked',
                  },
                );
                Navigator.pushNamed(
                  context,
                  AchievementDetailScreen.route,
                  arguments: AchievementDetailsScreenArgs(achievement: achievement),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
