import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/achievement_model.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class UserAchievementsDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _userAchievementRef = _db.from('user_achievements');
  static final SupabaseQueryBuilder _userAchievementProgressViewRef = _db.from('vu_user_achievement_progress');

  // Read
  static Future<List<Achievement>> getUserAchievements(
    BuildContext context, {
    required String userId,
  }) async {
    List<Map<String, dynamic>> response = [];
    List<Achievement> achievements = [];
    try {
      response = await _userAchievementProgressViewRef.select().eq(AchievementFields.userId, userId);

      for (var doc in response) {
        achievements.add(Achievement.fromJSON(doc));
      }

      return achievements;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error loading your achievements.");
      return [];
    }
  }

  static Future<Achievement?> getLatestMunroChallengeAchievement(BuildContext context, {required String userId}) async {
    try {
      final response = await _userAchievementProgressViewRef
          .select()
          .eq(AchievementFields.type, AchievementTypes.annualGoal)
          .eq(AchievementFields.userId, userId)
          .order(AchievementFields.dateTimeCreated, ascending: false)
          .limit(1)
          .single();

      return Achievement.fromJSON(response);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error loading your achievement.");
      return null;
    }
  }

  // Update
  static Future<void> updateUserAchievement({
    required Achievement achievement,
  }) async {
    await _userAchievementRef
        .upsert(achievement.toJSON())
        .eq(AchievementFields.userId, achievement.userId)
        .eq(AchievementFields.achievementId, achievement.achievementId)
        .select()
        .single();
  }
}
