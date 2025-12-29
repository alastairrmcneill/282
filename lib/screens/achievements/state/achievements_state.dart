import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class AchievementsState extends ChangeNotifier {
  final UserAchievementsRepository _userAchievementsRepository;
  final UserState _userState;
  final Logger _logger;
  AchievementsState(this._userAchievementsRepository, this._userState, this._logger);

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

// Get UserAchievements
  Future getUserAchievements() async {
    try {
      if (_userState.currentUser == null) return;
      setStatus = AchievementsStatus.loading;
      List<Achievement> allUserAchievements = await _userAchievementsRepository.getUserAchievements(
        userId: _userState.currentUser!.uid ?? "",
      );

      _achievements = allUserAchievements;
      List<Achievement> achievementsToShow = allUserAchievements
          .where((achievement) => achievement.completed && achievement.acknowledgedAt == null)
          .toList();

      _recentlyCompletedAchievements = achievementsToShow;

      List<Achievement> achievementsToReset = allUserAchievements
          .where((achievement) => !achievement.completed && achievement.acknowledgedAt != null)
          .toList();

      for (var achievement in achievementsToReset) {
        unacknowledgeAchievement(achievement: achievement);
      }
      setStatus = AchievementsStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setStatus = AchievementsStatus.error;
    }
  }

  // Mark an achievement as acknowledged
  Future<void> acknowledgeAchievement({required Achievement achievement}) async {
    try {
      achievement.acknowledgedAt = DateTime.now();
      await _userAchievementsRepository.updateUserAchievement(achievement: achievement);
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
    }
  }

  // Unmark an achievement as acknowledged
  Future<void> unacknowledgeAchievement({required Achievement achievement}) async {
    try {
      achievement.acknowledgedAt = null;
      await _userAchievementsRepository.updateUserAchievement(achievement: achievement);
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
    }
  }

  // Set annual goal
  Future<void> setMunroChallenge() async {
    try {
      Achievement achievement = _currentAchievement!;
      achievement.annualTarget = _achievementFormCount;

      await _userAchievementsRepository.updateUserAchievement(achievement: achievement);
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "Failed to set Munro Challenge",
        code: error.toString(),
      );
    }
  }

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
