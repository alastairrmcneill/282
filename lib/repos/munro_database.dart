import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_eight_two/models/models.dart';

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

  static Future<List<Map<String, dynamic>>> getAdditionalMunroData(BuildContext context) async {
    // Get additional data from firestore
    QuerySnapshot querySnapshot = await _munroRef.get();

    // Convert to list of maps
    List<Map<String, dynamic>> munroData = [];

    for (var doc in querySnapshot.docs) {
      munroData.add(doc.data() as Map<String, dynamic>);
    }

    print('Get Additional Munro Data: ${querySnapshot.docs.length} munros found');
    // Return the data as a list of maps
    return munroData;
  }
}

// Currently remaining - £5094.54 @ £165.00 per month
// If paying off currently - £4611.86
// If paying off £300 per month - ??
