import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class OnboardingRepository {
  final SupabaseClient _db;

  OnboardingRepository(this._db);

  SupabaseQueryBuilder get _posts => _db.from('vu_onboarding_feed');
  SupabaseQueryBuilder get _totals => _db.from('vu_onboarding_totals');

  Future<List<OnboardingFeedPostModel>> fetchFeedPosts() async {
    final response = await _posts.select();

    return response.map((e) => OnboardingFeedPostModel.fromMap(e)).toList();
  }

  Future<OnboardingTotalsModel> fetchTotals() async {
    final response = await _totals.select().single();

    return OnboardingTotalsModel.fromMap(response);
  }
}
