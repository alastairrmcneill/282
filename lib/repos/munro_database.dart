import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroDatabase {
  static final _db = FirebaseFirestore.instance;
  static final DocumentReference _munroRef = _db.collection('munroData').doc('allRatings');

  static Future<List<Munro>> loadBasicMunroData(BuildContext context) async {
    List<Munro> munroList = [];
    String dataString = await rootBundle.loadString('assets/munros.json');
    var data = jsonDecode(dataString);
    for (var munro in data) {
      munroList.add(Munro.fromJSON(munro));
    }

    return munroList;
  }

  static Future<Map<String, dynamic>> getAllAdditionalMunrosData(BuildContext context) async {
    // Get additional data from firestore
    DocumentSnapshot documentSnapshot = await _munroRef.get();

    AnalyticsService.logDatabaseRead(
      method: "MunroDatabase.getAllAdditionalMunrosData",
      collection: "munros",
      documentCount: 1,
      userId: null,
      documentId: null,
    );

    if (!documentSnapshot.exists) return {};

    var data = documentSnapshot.data() as Map<String, dynamic>? ?? {};
    Map<String, dynamic> munroData = data[MunroFields.ratings];

    return munroData;
  }
}

class MunroDatabaseSupabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _munrosRef = _db.from('vu_munros');

  static Future<List<Munro>> getMunroData(BuildContext context) async {
    List<Munro> munroList = [];
    try {
      final response = await _munrosRef.select();
      munroList = response.map((item) => Munro.fromSupabase(item)).toList();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error fetching munro data.");
    }

    return munroList;
  }
}
