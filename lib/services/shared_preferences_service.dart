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

  static Future<int> getLastFeedbackSurveyNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastFeedbackSurveyNumber') ?? -1;
  }

  static setLastFeedbackSurveyNumber(int latestFeedbackSurveyNumber) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt('lastFeedbackSurveyNumber', latestFeedbackSurveyNumber);
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

  static getShowWhatsNewDialog(String version) {
    final prefs = SharedPreferences.getInstance();
    return prefs.then((prefs) {
      return prefs.getBool('showWhatsNewDialog-$version') ?? true;
    });
  }

  static setShownWhatsNewDialog(String version) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('showWhatsNewDialog-$version', false);
    });
  }

  static Future<String?> getFirstAppVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('firstAppVersion');
  }

  static setFirstAppVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('firstAppVersion', version);
  }

  static Future<bool> getShowInAppOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showInAppOnboarding') ?? true;
  }

  static void setShowInAppOnboarding(bool bool) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('showInAppOnboarding', bool);
  }

  static Future<int> getOpenCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('open_count') ?? 0;
  }

  static setOpenCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('open_count', count);
  }
}
