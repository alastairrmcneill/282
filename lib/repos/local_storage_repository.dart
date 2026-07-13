import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageRepository {
  final SharedPreferences _prefs;

  LocalStorageRepository(this._prefs);

  Future<void> setGlobalCompletionCount(int count) async {
    await _prefs.setInt(LocalStorageFields.globalCompletionCount, count);
  }

  int? getGlobalCompletionCount() {
    return _prefs.getInt(LocalStorageFields.globalCompletionCount);
  }

  Future<void> setAgeGateAllowed(bool allowed) async {
    await _prefs.setBool(LocalStorageFields.ageGateAllowed, allowed);
  }

  bool? getAgeGateAllowed() {
    return _prefs.getBool(LocalStorageFields.ageGateAllowed);
  }
}

class LocalStorageFields {
  static const String globalCompletionCount = 'global_completion_count';
  static const String ageGateAllowed = 'age_gate_allowed';
}
