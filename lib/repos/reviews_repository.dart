import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class ReviewsRepository {
  final SupabaseClient _db;
  ReviewsRepository(this._db);
  SupabaseQueryBuilder get _table => _db.from('reviews');
  SupabaseQueryBuilder get _view => _db.from('vu_munro_reviews');
  SupabaseQueryBuilder get _ratingsBreakdownView => _db.from('vu_munro_ratings_breakdown');

  Future<void> create({required Review review}) async {
    await _table.insert(review.toJSON());
  }

  Future<void> update({required Review review}) async {
    await _table.update(review.toJSON()).eq(ReviewFields.uid, review.uid ?? "").select().single();
  }

  Future<List<Review>> readReviewsFromMunro({
    required int munroId,
    required List<String> excludedAuthorIds,
    int offset = 0,
  }) async {
    int pageSize = 10;

    final response = await _view
        .select()
        .not(ReviewFields.authorId, 'in', excludedAuthorIds)
        .eq(ReviewFields.munroId, munroId)
        .order(ReviewFields.dateTime, ascending: false)
        .range(offset, offset + pageSize - 1);

    return response.map((doc) => Review.fromJSON(doc)).toList();
  }

  Future<MunroRatingsBreakdown> readRatingsBreakdownFromMunro({required int munroId}) async {
    final response = await _ratingsBreakdownView.select().eq(MunroRatingsBreakdownFields.munroId, munroId).single();

    return MunroRatingsBreakdown.fromJSON(response);
  }

  Future<void> delete({required String uid}) async {
    await _table.delete().eq(ReviewFields.uid, uid);
  }
}
