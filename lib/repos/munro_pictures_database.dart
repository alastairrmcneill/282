import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroPicturesDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _munroPicturesRef = _db.from('munro_pictures');

  static Future<List<MunroPicture>> readMunroPictures(
    BuildContext context, {
    required int munroId,
    required List<String> excludedAuthorIds,
    int offset = 0,
    int count = 18,
  }) async {
    List<MunroPicture> munroPictures = [];
    List<Map<String, dynamic>> response = [];

    try {
      response = await _munroPicturesRef
          .select()
          .eq(MunroPictureFields.munroId, munroId)
          .not(MunroPictureFields.authorId, 'in', excludedAuthorIds)
          .eq(MunroPictureFields.privacy, Privacy.public)
          .order(MunroPictureFields.dateTime, ascending: false)
          .range(offset, offset + count - 1);

      for (var doc in response) {
        MunroPicture munroPicture = MunroPicture.fromJSON(doc);
        munroPictures.add(munroPicture);
      }
      return munroPictures;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error fetching munro pictures.");
      return munroPictures;
    }
  }

  static Future<List<MunroPicture>> readProfilePictures(
    BuildContext context, {
    required String profileId,
    required List<String> excludedAuthorIds,
    int offset = 0,
    int count = 18,
  }) async {
    List<MunroPicture> munroPictures = [];
    List<Map<String, dynamic>> response = [];

    try {
      response = await _munroPicturesRef
          .select()
          .eq(MunroPictureFields.authorId, profileId)
          .not(MunroPictureFields.authorId, 'in', excludedAuthorIds)
          .eq(MunroPictureFields.privacy, Privacy.public)
          .order(MunroPictureFields.dateTime, ascending: false)
          .range(offset, offset + count - 1);

      for (var doc in response) {
        MunroPicture munroPicture = MunroPicture.fromJSON(doc);
        munroPictures.add(munroPicture);
      }
      return munroPictures;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error fetching munro pictures.");
      return munroPictures;
    }
  }

  static Future<void> createMunroPictures(BuildContext context, {required List<MunroPicture> munroPictures}) async {
    try {
      await _munroPicturesRef.insert(munroPictures.map((e) => e.toJSON()).toList());
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error uploading munro pictures.");
    }
  }

  static Future deleteMunroPicturesByUrls(BuildContext context, {required List<String> imageURLs}) async {
    try {
      await _munroPicturesRef.delete().inFilter(MunroPictureFields.imageUrl, imageURLs);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error deleting munro pictures.");
    }
  }
}
