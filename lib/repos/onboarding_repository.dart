import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class OnboardingRepository {
  final SupabaseClient _db;

  OnboardingRepository(this._db);

  SupabaseQueryBuilder get _posts => _db.from('vu_onboarding_feed');
  SupabaseQueryBuilder get _totals => _db.from('vu_onboarding_totals');
  SupabaseQueryBuilder get _acheivements => _db.from('vu_onboarding_achievements');

  Future<List<OnboardingFeedPost>> fetchFeedPosts() async {
    final response = await _posts.select();

    return response.map((e) => OnboardingFeedPost.fromMap(e)).toList();
  }

  Future<OnboardingTotals> fetchTotals() async {
    final response = await _totals.select().single();

    return OnboardingTotals.fromMap(response);
  }

  Future<List<OnboardingAchievements>> fetchAchievements() async {
    final response = await _acheivements.select();

    return response.map((e) => OnboardingAchievements.fromMap(e)).toList();
  }
}
