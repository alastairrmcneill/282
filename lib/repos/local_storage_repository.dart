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
}

class LocalStorageFields {
  static const String globalCompletionCount = 'global_completion_count';
}
