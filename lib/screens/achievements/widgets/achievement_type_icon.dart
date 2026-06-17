import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

IconData achievementTypeIcon(String type) {
  switch (type) {
    case AchievementTypes.totalCount:
      return Icons.terrain_rounded;
    case AchievementTypes.annualGoal:
      return Icons.calendar_today_rounded;
    case AchievementTypes.areaGoal:
      return Icons.location_on_rounded;
    case AchievementTypes.multiMunroDay:
      return Icons.local_fire_department_rounded;
    case AchievementTypes.highestMunros:
      return Icons.trending_up_rounded;
    case AchievementTypes.lowestMunros:
      return Icons.gps_fixed_rounded;
    case AchievementTypes.monthlyMunro:
      return Icons.ac_unit_rounded;
    case AchievementTypes.nameGoal:
      return Icons.tag_rounded;
    default:
      return Icons.terrain_rounded;
  }
}

String achievementCategoryLabel(String type) {
  switch (type) {
    case AchievementTypes.totalCount:
      return 'Total Climbs';
    case AchievementTypes.annualGoal:
      return 'Annual Challenges';
    case AchievementTypes.areaGoal:
      return 'Area Completions';
    case AchievementTypes.multiMunroDay:
      return 'Multi-Munro Days';
    case AchievementTypes.highestMunros:
      return 'Highest Munros';
    case AchievementTypes.lowestMunros:
      return 'Lowest Munros';
    case AchievementTypes.monthlyMunro:
      return 'All Seasons';
    case AchievementTypes.nameGoal:
      return 'Name Quests';
    default:
      return type;
  }
}
