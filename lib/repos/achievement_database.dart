import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AchievementDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _usersRef = _db.collection('users');

  // Read all user achievements
  static Future<List<Achievement>> readAllUserAchievements(BuildContext context, {required String userUid}) async {
    List<Achievement> achievements = [];
    try {
      CollectionReference achievementRef = _usersRef.doc(userUid).collection('userAchievements');

      QuerySnapshot querySnapshot = await achievementRef.get();

      for (QueryDocumentSnapshot<Object?> document in querySnapshot.docs) {
        Map<String, Object?> data = document.data() as Map<String, Object?>;

        Achievement achievement = Achievement.fromJSON(data);

        achievements.add(achievement);
      }

      return achievements;
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error fetching your achievements.");
      return [];
    }
  }

  // Update user achievement
  static Future<void> updateUserAchievement(
    BuildContext context, {
    required String userUid,
    required Achievement achievement,
  }) async {
    try {
      CollectionReference achievementRef = _usersRef.doc(userUid).collection('userAchievements');

      await achievementRef.doc(achievement.uid).set(achievement.toJSON());
    } on FirebaseException catch (error) {
      showErrorDialog(context, message: error.message ?? "There was an error updating your achievement.");
    }
  }
}
