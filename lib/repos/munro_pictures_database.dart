import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroPicturesDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _munroPicturesRef = _db.collection('munroPictures');

  static Future<List<MunroPicture>> readMunroPictures(
    BuildContext context, {
    required String munroId,
    required String? lastPictureId,
    int count = 18,
  }) async {
    List<MunroPicture> munroPictures = [];
    QuerySnapshot querySnapshot;

    try {
      if (lastPictureId == null) {
        // Load first bathc
        querySnapshot = await _munroPicturesRef
            .where(MunroPictureFields.munroId, isEqualTo: munroId)
            .where(MunroPictureFields.privacy, isEqualTo: Privacy.public)
            .orderBy(PostFields.dateTime, descending: true)
            .limit(count)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "MunroPicturesDatabase.readMunroPictures.firstBatch",
          collection: "munroPictures",
          documentCount: querySnapshot.docs.length,
          userId: null,
          documentId: munroId,
        );
      } else {
        final lastPictureDoc = await _munroPicturesRef.doc(lastPictureId).get();

        if (!lastPictureDoc.exists) return [];

        querySnapshot = await _munroPicturesRef
            .where(MunroPictureFields.munroId, isEqualTo: munroId)
            .where(MunroPictureFields.privacy, isEqualTo: Privacy.public)
            .orderBy(PostFields.dateTime, descending: true)
            .startAfterDocument(lastPictureDoc)
            .limit(count)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "MunroPicturesDatabase.readMunroPictures.paginate",
          collection: "munroPictures",
          documentCount: querySnapshot.docs.length,
          userId: null,
          documentId: munroId,
        );
      }

      for (var doc in querySnapshot.docs) {
        MunroPicture munroPicture = MunroPicture.fromJSON(doc.data() as Map<String, dynamic>);

        munroPictures.add(munroPicture);
      }
      return munroPictures;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error fetching munro pictures.");
      return munroPictures;
    }
  }

  static Future<List<MunroPicture>> readProfilePictures(
    BuildContext context, {
    required String profileId,
    required String? lastPictureId,
    int count = 18,
  }) async {
    List<MunroPicture> munroPictures = [];
    QuerySnapshot querySnapshot;

    try {
      if (lastPictureId == null) {
        // Load first bathc
        querySnapshot = await _munroPicturesRef
            .where(MunroPictureFields.authorId, isEqualTo: profileId)
            .orderBy(PostFields.dateTime, descending: true)
            .limit(count)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "MunroPicturesDatabase.readProfilePictures.firstBatch",
          collection: "munroPictures",
          documentCount: querySnapshot.docs.length,
          userId: profileId,
          documentId: null,
        );
      } else {
        final lastPictureDoc = await _munroPicturesRef.doc(lastPictureId).get();

        if (!lastPictureDoc.exists) return [];

        querySnapshot = await _munroPicturesRef
            .where(MunroPictureFields.authorId, isEqualTo: profileId)
            .orderBy(PostFields.dateTime, descending: true)
            .startAfterDocument(lastPictureDoc)
            .limit(count)
            .get();

        AnalyticsService.logDatabaseRead(
          method: "MunroPicturesDatabase.readProfilePictures.paginate",
          collection: "munroPictures",
          documentCount: querySnapshot.docs.length,
          userId: profileId,
          documentId: null,
        );
      }

      for (var doc in querySnapshot.docs) {
        MunroPicture munroPicture = MunroPicture.fromJSON(doc.data() as Map<String, dynamic>);

        munroPictures.add(munroPicture);
      }
      return munroPictures;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error fetching munro pictures.");
      return munroPictures;
    }
  }
}

class MunroPicturesDatabaseSupabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _munroPicturesRef = _db.from('munro_pictures');

  static Future<List<MunroPicture>> readMunroPictures(
    BuildContext context, {
    required String munroId,
    required List<String> excludedAuthorIds,
    int offset = 0,
    int count = 18,
  }) async {
    List<MunroPicture> munroPictures = [];
    List<Map<String, dynamic>> response = [];

    try {
      response = await _munroPicturesRef
          .select()
          .eq(MunroPictureFields.munroIdSupbase, munroId)
          .not(MunroPictureFields.authorIdSupbase, 'in', excludedAuthorIds)
          .eq(MunroPictureFields.privacy, Privacy.public)
          .order(MunroPictureFields.dateTimeSupbase, ascending: false)
          .range(offset, offset + count - 1);

      for (var doc in response) {
        MunroPicture munroPicture = MunroPicture.fromSupabase(doc);
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
          .eq(MunroPictureFields.authorIdSupbase, profileId)
          .not(MunroPictureFields.authorIdSupbase, 'in', excludedAuthorIds)
          .eq(MunroPictureFields.privacy, Privacy.public)
          .order(MunroPictureFields.dateTimeSupbase, ascending: false)
          .range(offset, offset + count - 1);

      for (var doc in response) {
        MunroPicture munroPicture = MunroPicture.fromSupabase(doc);
        munroPictures.add(munroPicture);
      }
      return munroPictures;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error fetching munro pictures.");
      return munroPictures;
    }
  }
}
