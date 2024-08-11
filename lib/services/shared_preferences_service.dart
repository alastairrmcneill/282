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

  static Future<bool> getMapTerrain() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('mapTerrain') ?? true;
  }

  static Future<void> setMapTerrain(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('mapTerrain', value);
  }

  static Future<String> getLastFeedbackSurveyDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastFeedbackSurveyDate') ?? '01/01/2000';
  }

  static setLastFeedbackSurveyDate(String latestFeedbackSurveyDateString) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('lastFeedbackSurveyDate', latestFeedbackSurveyDateString);
    });
  }

  static Future<String> getLastAppUpdateDialogDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('getLastAppUpdateDialogDate') ?? '01/01/2000';
  }

  static setLastAppUpdateDialogDate(String date) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('getLastAppUpdateDialogDate', date);
    });
  }
}
