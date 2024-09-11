import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/achievement_model.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AchievementsDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _achievementRef = _db.collection('achievements');

  List<Achievement> achievements = [
    Achievement(
      uid: "munrosCompletedAllTime25",
      name: "Completed 25 Munros",
      description: "You have completed 25 Munros",
      type: "totalCount",
      completed: false,
      criteria: {CriteriaFields.count: 25},
      progress: 0,
    ),
    Achievement(
      uid: "munrosCompletedAllTime50",
      name: "Completed 50 Munros",
      description: "You have completed 50 Munros",
      type: "totalCount",
      completed: false,
      criteria: {CriteriaFields.count: 50},
      progress: 0,
    ),
    Achievement(
      uid: "munrosCompletedAllTime82",
      name: "Completed 82 Munros",
      description: "Only 200 left!",
      type: "totalCount",
      completed: false,
      criteria: {CriteriaFields.count: 82},
      progress: 0,
    ),
    Achievement(
      uid: "munrosCompletedAllTime100",
      name: "Completed 100 Munros",
      description: "You have completed 100 Munros",
      type: "totalCount",
      completed: false,
      criteria: {CriteriaFields.count: 100},
      progress: 0,
    ),
    Achievement(
      uid: "munrosCompletedAllTime150",
      name: "Completed 150 Munros",
      description: "You have completed 150 Munros",
      type: "totalCount",
      completed: false,
      criteria: {CriteriaFields.count: 150},
      progress: 0,
    ),
    Achievement(
      uid: "munrosCompletedAllTime182",
      name: "Completed 182 Munros",
      description: "Only 100 left!",
      type: "totalCount",
      completed: false,
      criteria: {CriteriaFields.count: 182},
      progress: 0,
    ),
    Achievement(
      uid: "munrosCompletedAllTime200",
      name: "Completed 200 Munros",
      description: "You have completed 200 Munros",
      type: "totalCount",
      completed: false,
      criteria: {CriteriaFields.count: 200},
      progress: 0,
    ),
    Achievement(
      uid: "munrosCompletedAllTime250",
      name: "Completed 250 Munros",
      description: "You have completed 250 Munros",
      type: "totalCount",
      completed: false,
      criteria: {CriteriaFields.count: 250},
      progress: 0,
    ),
    Achievement(
      uid: "munrosCompletedAllTime282",
      name: "Completed 282 Munros",
      description: "You have completed all 282 Munros! Well done!",
      type: "totalCount",
      completed: false,
      criteria: {CriteriaFields.count: 282},
      progress: 0,
    ),
    Achievement(
      uid: "highestMunros10",
      name: "High climber",
      description: "Climb the top 10 highest Munros",
      type: "tallestMunros",
      completed: false,
      criteria: {CriteriaFields.count: 10},
      progress: 0,
    ),
    Achievement(
      uid: "lowestMunros10",
      name: "Low climber",
      description: "Climb the top 10 lowest Munros",
      type: "lowestMunros",
      completed: false,
      criteria: {CriteriaFields.count: 10},
      progress: 0,
    ),
    Achievement(
      uid: "munroEveryMonth",
      name: "Montly Munroer",
      description: "Climb a munro in each month of the year",
      type: "monthlyMunro",
      completed: false,
      criteria: {CriteriaFields.count: 1},
      progress: 0,
    ),
    Achievement(
      uid: "multiMunroDay2",
      name: "Multi Munro Day - 2",
      description: "Climb 2 munros in a day",
      type: "multiMunroDay",
      completed: false,
      criteria: {CriteriaFields.count: 2},
      progress: 0,
    ),
    Achievement(
      uid: "multiMunroDay3",
      name: "Multi Munro Day - 3",
      description: "Climb 3 munros in a day",
      type: "multiMunroDay",
      completed: false,
      criteria: {CriteriaFields.count: 3},
      progress: 0,
    ),
    Achievement(
      uid: "multiMunroDay4",
      name: "Multi Munro Day - 4",
      description: "Climb 4 munros in a day",
      type: "multiMunroDay",
      completed: false,
      criteria: {CriteriaFields.count: 4},
      progress: 0,
    ),
    Achievement(
      uid: "multiMunroDay5",
      name: "Multi Munro Day - 5",
      description: "Climb 5 munros in a day",
      type: "multiMunroDay",
      completed: false,
      criteria: {CriteriaFields.count: 5},
      progress: 0,
    ),
    Achievement(
      uid: "multiMunroDay6",
      name: "Multi Munro Day - 6",
      description: "Climb 6 munros in a day",
      type: "multiMunroDay",
      completed: false,
      criteria: {CriteriaFields.count: 6},
      progress: 0,
    ),
    Achievement(
      uid: "multiMunroDay7",
      name: "Multi Munro Day - 7",
      description: "Climb 7 munros in a day",
      type: "multiMunroDay",
      completed: false,
      criteria: {CriteriaFields.count: 7},
      progress: 0,
    ),
  ];

  Future<void> updateAchievements() async {
    for (Achievement achievement in achievements) {
      await _achievementRef.doc(achievement.uid).set(achievement.toJSON());
    }
  }

  static Future<List<Achievement>> getAllAchievements(BuildContext context) async {
    List<Achievement> achievements = [];
    try {
      QuerySnapshot querySnapshot = await _achievementRef.get();
      AnalyticsService.logDatabaseRead(
        method: "AchievementsDatabase.getAllAchievements",
        collection: 'achievements',
        documentCount: querySnapshot.docs.length,
        userId: null,
        documentId: null,
        additionalData: null,
      );
      for (var doc in querySnapshot.docs) {
        achievements.add(Achievement.fromJSON(doc.data() as Map<String, dynamic>));
      }
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an loading the achievements.");
    } on Exception catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.toString());
    }
    return achievements;
  }
}
