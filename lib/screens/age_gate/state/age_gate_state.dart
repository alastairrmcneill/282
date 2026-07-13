import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/repos/repos.dart';

enum AgeGateStatus { checking, allowed, restricted, needsConfirmation, needsBirthdate }

class AgeGateState extends ChangeNotifier {
  static const int _minimumAge = 13;

  final AgeGateRepository _ageGateRepository;
  final LocalStorageRepository _localStorageRepository;
  final Analytics _analytics;
  final Logger _logger;

  AgeGateState(
    this._ageGateRepository,
    this._localStorageRepository,
    this._analytics,
    this._logger,
  );

  AgeGateStatus _status = AgeGateStatus.checking;
  AgeGateStatus get status => _status;

  Future<void> checkAgeGate() async {
    final cachedAllowed = _localStorageRepository.getAgeGateAllowed();
    if (cachedAllowed != null) {
      _setStatus(cachedAllowed ? AgeGateStatus.allowed : AgeGateStatus.restricted);
      _trackResolved(method: 'cached', allowed: cachedAllowed);
      return;
    }

    // Explain why we're asking before the native dialog interrupts them -
    // firing the system prompt with zero context tanks opt-in rates.
    _setStatus(AgeGateStatus.needsConfirmation);
    _analytics.track(AnalyticsEvent.ageGateConfirmationShown);
  }

  Future<void> confirmAge() async {
    _analytics.track(AnalyticsEvent.ageGateConfirmTapped);
    _setStatus(AgeGateStatus.checking);

    try {
      final declaredAge = await _ageGateRepository.requestDeclaredAgeRange();
      if (declaredAge != null) {
        await _resolve(declaredAge >= _minimumAge, method: 'native');
        return;
      }
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
    }

    // Native age range unavailable or declined - ask the user directly.
    _setStatus(AgeGateStatus.needsBirthdate);
    _analytics.track(AnalyticsEvent.ageGateBirthdatePromptShown);
  }

  Future<void> submitBirthdate(DateTime birthdate) async {
    await _resolve(_ageFromBirthdate(birthdate) >= _minimumAge, method: 'birthdate');
  }

  Future<void> _resolve(bool allowed, {required String method}) async {
    await _localStorageRepository.setAgeGateAllowed(allowed);
    _setStatus(allowed ? AgeGateStatus.allowed : AgeGateStatus.restricted);
    _trackResolved(method: method, allowed: allowed);
  }

  void _trackResolved({required String method, required bool allowed}) {
    _analytics.track(
      AnalyticsEvent.ageGateResolved,
      props: {
        AnalyticsProp.method: method,
        AnalyticsProp.status: allowed ? 'allowed' : 'restricted',
      },
    );
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
