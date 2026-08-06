import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/helpers/helpers.dart';
import 'package:two_eight_two/models/models.dart';

class OnboardingRepository {
  final SupabaseClient _db;

  OnboardingRepository(this._db);

  SupabaseQueryBuilder get _posts => _db.from('vu_onboarding_feed');
  SupabaseQueryBuilder get _totals => _db.from('vu_onboarding_totals');
  SupabaseQueryBuilder get _acheivements => _db.from('vu_onboarding_achievements');

  // Onboarding runs right after app launch, often just as the OS finishes
  // handing the process its network interface back — that's exactly when a
  // reused connection is most likely to have gone stale underneath us, so
  // these reads get one short retry on transient connection errors.
  Future<List<OnboardingFeedPost>> fetchFeedPosts() async {
    final response = await withNetworkRetry(() => _posts.select());

    return response.map((e) => OnboardingFeedPost.fromMap(e)).toList();
  }

  Future<OnboardingTotals> fetchTotals() async {
    final response = await withNetworkRetry(() => _totals.select().single());

    return OnboardingTotals.fromMap(response);
  }

  Future<List<OnboardingAchievements>> fetchAchievements() async {
    final response = await withNetworkRetry(() => _acheivements.select());

    return response.map((e) => OnboardingAchievements.fromMap(e)).toList();
  }
}
