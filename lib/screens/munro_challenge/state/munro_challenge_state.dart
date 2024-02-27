import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class MunroChallengeState extends ChangeNotifier {
  MunroChallengeStatus _status = MunroChallengeStatus.initial;
  Error _error = Error();
  List<MunroChallenge> _previousMunroChallenges = [];
  MunroChallenge? _currentMunroChallenge;
  int _munroChallengeCountForm = 0;

  MunroChallengeStatus get status => _status;
  Error get error => _error;
  List<MunroChallenge> get previousMunroChallenges => _previousMunroChallenges;
  MunroChallenge? get currentMunroChallenge => _currentMunroChallenge;
  int get munroChallengeCountForm => _munroChallengeCountForm;

  set setStatus(MunroChallengeStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = MunroChallengeStatus.error;
    _error = error;
    notifyListeners();
  }

  set setPreviousMunroChallenges(List<MunroChallenge> previousMunroChallenges) {
    _previousMunroChallenges = previousMunroChallenges;
    notifyListeners();
  }

  set setCurrentMunroChallenge(MunroChallenge? currentMunroChallenge) {
    _currentMunroChallenge = currentMunroChallenge;
    notifyListeners();
  }

  set setMunroChallengeCountForm(int munroChallengeCountForm) {
    _munroChallengeCountForm = munroChallengeCountForm;
    notifyListeners();
  }

  void reset() {
    _status = MunroChallengeStatus.initial;
    _error = Error();
    _munroChallengeCountForm = 0;
  }
}

enum MunroChallengeStatus { initial, loading, loaded, error }
