import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/achievement_model.dart';

class UserAchievementsRepository {
  final SupabaseClient _db;
  UserAchievementsRepository(this._db);
  SupabaseQueryBuilder get _table => _db.from('user_achievements');
  SupabaseQueryBuilder get _view => _db.from('vu_user_achievement_progress');

  // Read
  Future<List<Achievement>> getUserAchievements({required String userId}) async {
    final response = await _view.select().eq(AchievementFields.userId, userId);
    return response.map((doc) => Achievement.fromJSON(doc)).toList();
  }

  Future<Achievement?> getLatestMunroChallengeAchievement({required String userId}) async {
    final response = await _view
        .select()
        .eq(AchievementFields.type, AchievementTypes.annualGoal)
        .eq(AchievementFields.userId, userId)
        .order(AchievementFields.dateTimeCreated, ascending: false)
        .limit(1)
        .single();

    return Achievement.fromJSON(response);
  }

  // Update
  Future<void> updateUserAchievement({
    required Achievement achievement,
  }) async {
    await _table
        .upsert(achievement.toJSON())
        .eq(AchievementFields.userId, achievement.userId)
        .eq(AchievementFields.achievementId, achievement.achievementId)
        .select()
        .single();
  }
}
