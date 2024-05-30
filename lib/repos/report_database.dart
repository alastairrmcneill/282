import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReportDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _reportsRef = _db.collection('reports');

  static Future<void> create(BuildContext context, {required Report report}) async {
    try {
      DocumentReference ref = _reportsRef.doc();
      Report newReport = report.copyWith(uid: ref.id);
      await ref.set(newReport.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an sending your report.");
    }
  }
}
