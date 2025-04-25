import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';

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
    // Check if user logged in
  }

  static Future<Map<String, dynamic>> getAllAdditionalMunrosData(BuildContext context) async {
    // Get additional data from firestore
    DocumentSnapshot documentSnapshot = await _munroRef.get();
    print(
        "🚀 ~ MunroDatabase ~ Future<Map<String,dynamic>>getAllAdditionalMunrosData ~ documentSnapshot: ${documentSnapshot.data()}");

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
