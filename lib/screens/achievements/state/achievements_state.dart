import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class AchievementsState extends ChangeNotifier {
  AchievementsStatus _status = AchievementsStatus.initial;
  Error _error = Error();
  List<Achievement> _achievements = [];
  List<Achievement> _recentlyCompletedAchievements = [];
  Achievement? _currentAchievement;
  int _achievementFormCount = 0;

  AchievementsStatus get status => _status;
  Error get error => _error;
  List<Achievement> get achievements => _achievements;
  List<Achievement> get recentlyCompletedAchievements => _recentlyCompletedAchievements;
  Achievement? get currentAchievement => _currentAchievement;
  int get achievementFormCount => _achievementFormCount;

  set setStatus(AchievementsStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = AchievementsStatus.error;
    _error = error;
    notifyListeners();
  }

  set setAchievements(List<Achievement> achievements) {
    _achievements = achievements;
    notifyListeners();
  }

  set setRecentlyCompletedAchievements(List<Achievement> achievements) {
    _recentlyCompletedAchievements = achievements;
    notifyListeners();
  }

  set addRecentlyCompletedAchievement(Achievement achievement) {
    _recentlyCompletedAchievements.add(achievement);
    notifyListeners();
  }

  set setCurrentAchievement(Achievement? achievement) {
    _currentAchievement = achievement;
    notifyListeners();
  }

  set setAchievementFormCount(int achievementFormCount) {
    _achievementFormCount = achievementFormCount;
    notifyListeners();
  }

  void reset() {
    _status = AchievementsStatus.initial;
    _error = Error();
    _currentAchievement = null;
    _recentlyCompletedAchievements = [];
    _achievementFormCount = 0;
  }

  void resetAll() {
    reset();
    _achievements = [];
  }
}

enum AchievementsStatus { initial, loading, loaded, error }
