import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class MunroPicturesRepository {
  final SupabaseClient _db;
  MunroPicturesRepository(this._db);
  SupabaseQueryBuilder get _table => _db.from('munro_pictures');

  Future<List<MunroPicture>> readMunroPictures({
    required int munroId,
    required List<String> excludedAuthorIds,
    int offset = 0,
    int count = 18,
  }) async {
    final response = await _table
        .select()
        .eq(MunroPictureFields.munroId, munroId)
        .not(MunroPictureFields.authorId, 'in', excludedAuthorIds)
        .eq(MunroPictureFields.privacy, Privacy.public)
        .order(MunroPictureFields.dateTime, ascending: false)
        .range(offset, offset + count - 1);

    return response.map((doc) => MunroPicture.fromJSON(doc)).toList();
  }

  Future<List<MunroPicture>> readProfilePictures({
    required String profileId,
    required List<String> excludedAuthorIds,
    int offset = 0,
    int count = 18,
  }) async {
    final response = await _table
        .select()
        .eq(MunroPictureFields.authorId, profileId)
        .not(MunroPictureFields.authorId, 'in', excludedAuthorIds)
        .eq(MunroPictureFields.privacy, Privacy.public)
        .order(MunroPictureFields.dateTime, ascending: false)
        .range(offset, offset + count - 1);

    return response.map((doc) => MunroPicture.fromJSON(doc)).toList();
  }

  Future<void> createMunroPictures({required List<MunroPicture> munroPictures}) async {
    await _table.insert(munroPictures.map((e) => e.toJSON()).toList());
  }

  Future deleteMunroPicturesByUrls({required List<String> imageURLs}) async {
    await _table.delete().inFilter(MunroPictureFields.imageUrl, imageURLs);
  }
}
