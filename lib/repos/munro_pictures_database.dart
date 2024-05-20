import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
            .orderBy(PostFields.dateTime, descending: true)
            .limit(count)
            .get();
      } else {
        final lastPictureDoc = await _munroPicturesRef.doc(lastPictureId).get();

        if (!lastPictureDoc.exists) return [];

        querySnapshot = await _munroPicturesRef
            .where(MunroPictureFields.munroId, isEqualTo: munroId)
            .orderBy(PostFields.dateTime, descending: true)
            .startAfterDocument(lastPictureDoc)
            .limit(count)
            .get();
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
      } else {
        final lastPictureDoc = await _munroPicturesRef.doc(lastPictureId).get();

        if (!lastPictureDoc.exists) return [];

        querySnapshot = await _munroPicturesRef
            .where(MunroPictureFields.authorId, isEqualTo: profileId)
            .orderBy(PostFields.dateTime, descending: true)
            .startAfterDocument(lastPictureDoc)
            .limit(count)
            .get();
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
