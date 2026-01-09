import 'package:shared_preferences/shared_preferences.dart';

class AppFlagsRepository {
  AppFlagsRepository(this._prefs);
  final SharedPreferences _prefs;

  static const _kShowBulkMunroDialog = 'showBulkMunroDialog';
  static const _kMapTerrain = 'mapTerrain';
  static const _kLastFeedbackSurveyNumber = 'lastFeedbackSurveyNumber';
  static const _kLastAppUpdateDialogDate = 'lastAppUpdateDialogDate';
  static const _kFirstAppVersion = 'firstAppVersion';
  static const _kShowInAppOnboarding = 'showInAppOnboarding';
  static const _kOpenCount = 'open_count';

  bool get mapTerrain => _prefs.getBool(_kMapTerrain) ?? true;
  Future<void> setMapTerrain(bool v) async {
    final ok = await _prefs.setBool(_kMapTerrain, v);
    if (!ok) throw Exception('Failed to persist $_kMapTerrain');
  }

  bool get showBulkMunroDialog => _prefs.getBool(_kShowBulkMunroDialog) ?? true;
  Future<void> setShowBulkMunroDialog(bool v) async {
    final ok = await _prefs.setBool(_kShowBulkMunroDialog, v);
    if (!ok) throw Exception('Failed to persist $_kShowBulkMunroDialog');
  }

  int get lastFeedbackSurveyNumber => _prefs.getInt(_kLastFeedbackSurveyNumber) ?? -1;
  Future<void> setLastFeedbackSurveyNumber(int v) async {
    final ok = await _prefs.setInt(_kLastFeedbackSurveyNumber, v);
    if (!ok) throw Exception('Failed to persist $_kLastFeedbackSurveyNumber');
  }

  String get lastAppUpdateDialogDate => _prefs.getString(_kLastAppUpdateDialogDate) ?? '2000-01-01';
  Future<void> setLastAppUpdateDialogDate(String isoDate) async {
    final ok = await _prefs.setString(_kLastAppUpdateDialogDate, isoDate);
    if (!ok) throw Exception('Failed to persist $_kLastAppUpdateDialogDate');
  }

  bool showWhatsNewDialog(String version) => _prefs.getBool('showWhatsNewDialog-$version') ?? true;

  Future<void> setShownWhatsNewDialog(String version) async {
    final ok = await _prefs.setBool('showWhatsNewDialog-$version', false);
    if (!ok) throw Exception('Failed to persist showWhatsNewDialog-$version');
  }

  String? get firstAppVersion => _prefs.getString(_kFirstAppVersion);
  Future<void> setFirstAppVersion(String v) async {
    final ok = await _prefs.setString(_kFirstAppVersion, v);
    if (!ok) throw Exception('Failed to persist $_kFirstAppVersion');
  }

  bool showInAppOnboarding(String userId) => _prefs.getBool("$_kShowInAppOnboarding-$userId") ?? true;
  Future<void> setShowInAppOnboarding(String userId, bool v) async {
    final ok = await _prefs.setBool("$_kShowInAppOnboarding-$userId", v);
    if (!ok) throw Exception('Failed to persist $_kShowInAppOnboarding');
  }

  int get openCount => _prefs.getInt(_kOpenCount) ?? 0;
  Future<void> setOpenCount(int v) async {
    final ok = await _prefs.setInt(_kOpenCount, v);
    if (!ok) throw Exception('Failed to persist $_kOpenCount');
  }

  Future<void> incrementOpenCount() => setOpenCount(openCount + 1);
}
