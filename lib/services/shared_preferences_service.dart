import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static Future<void> setShowBulkMunroDialog(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showBulkMunroDialog', value);
  }

  static Future<bool> getShowBulkMunroDialog() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showBulkMunroDialog') ?? true;
  }
}
