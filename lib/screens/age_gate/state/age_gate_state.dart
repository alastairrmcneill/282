import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/repos/repos.dart';

enum AgeGateStatus { checking, allowed, restricted, needsBirthdate }

class AgeGateState extends ChangeNotifier {
  static const int _minimumAge = 13;

  final AgeGateRepository _ageGateRepository;
  final LocalStorageRepository _localStorageRepository;
  final Logger _logger;

  AgeGateState(
    this._ageGateRepository,
    this._localStorageRepository,
    this._logger,
  );

  AgeGateStatus _status = AgeGateStatus.checking;
  AgeGateStatus get status => _status;

  Future<void> checkAgeGate() async {
    // Apple-only requirement - Android has no equivalent obligation, so skip
    // the check entirely rather than asking users for age with no reason.
    if (!Platform.isIOS) {
      _setStatus(AgeGateStatus.allowed);
      return;
    }

    final cachedAllowed = _localStorageRepository.getAgeGateAllowed();
    if (cachedAllowed != null) {
      _setStatus(cachedAllowed ? AgeGateStatus.allowed : AgeGateStatus.restricted);
      return;
    }

    _setStatus(AgeGateStatus.checking);

    try {
      final declaredAge = await _ageGateRepository.requestDeclaredAgeRange();
      if (declaredAge != null) {
        await _resolve(declaredAge >= _minimumAge);
        return;
      }
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
    }

    // Native age range unavailable or declined - ask the user directly.
    _setStatus(AgeGateStatus.needsBirthdate);
  }

  Future<void> submitBirthdate(DateTime birthdate) async {
    await _resolve(_ageFromBirthdate(birthdate) >= _minimumAge);
  }

  Future<void> _resolve(bool allowed) async {
    await _localStorageRepository.setAgeGateAllowed(allowed);
    _setStatus(allowed ? AgeGateStatus.allowed : AgeGateStatus.restricted);
  }

  int _ageFromBirthdate(DateTime birthdate) {
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    if (now.month < birthdate.month || (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }
    return age;
  }

  void _setStatus(AgeGateStatus status) {
    _status = status;
    notifyListeners();
  }
}
