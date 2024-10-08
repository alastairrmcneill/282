import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';

class MunroDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _munroRef = _db.collection('munros');

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

  static Future<List<Map<String, dynamic>>> getAllAdditionalMunrosData(BuildContext context) async {
    // Get additional data from firestore
    QuerySnapshot querySnapshot = await _munroRef.get();

    AnalyticsService.logDatabaseRead(
      method: "MunroDatabase.getAllAdditionalMunrosData",
      collection: "munros",
      documentCount: querySnapshot.docs.length,
      userId: null,
      documentId: null,
    );

    // Convert to list of maps
    List<Map<String, dynamic>> munroData = [];

    for (var doc in querySnapshot.docs) {
      munroData.add(doc.data() as Map<String, dynamic>);
    }

    // Return the data as a list of maps
    return munroData;
  }

  static Future<Map<String, dynamic>> getAdditionalMunroData(BuildContext context, {required String munroId}) async {
    // Get additional data from firestore
    DocumentSnapshot querySnapshot = await _munroRef.doc(munroId).get();

    AnalyticsService.logDatabaseRead(
      method: "MunroDatabase.getAdditionalMunroData",
      collection: "munros",
      documentCount: querySnapshot.exists ? 1 : 0,
      userId: null,
      documentId: munroId,
    );
    // Convert to map
    if (!querySnapshot.exists) {
      return {};
    }
    Map<String, dynamic> munroData = querySnapshot.data() as Map<String, dynamic>;

    // Return the data as a list of maps
    return munroData;
  }
}
