import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class AchievementsState extends ChangeNotifier {
  AchievementsStatus _status = AchievementsStatus.initial;
  Error _error = Error();
  List<Achievement> _achievements = [];
  Achievement? _currentAchievement;

  AchievementsStatus get status => _status;
  Error get error => _error;
  List<Achievement> get achievements => _achievements;
  Achievement? get currentAchievement => _currentAchievement;

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

  set setCurrentAchievement(Achievement? achievement) {
    _currentAchievement = achievement;
    notifyListeners();
  }
}

enum AchievementsStatus { initial, loading, loaded, error }
