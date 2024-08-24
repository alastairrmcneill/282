import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FeedbackDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _feedbackRef = _db.collection('feedback');

  static Future<void> create(BuildContext context, {required AppFeedback feedback}) async {
    try {
      DocumentReference ref = _feedbackRef.doc();
      AppFeedback newFeedback = feedback.copyWith(uid: ref.id);
      await ref.set(newFeedback.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an sending your app feedback.");
    }
  }
}
