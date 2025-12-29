import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_eight_two/models/models.dart';

class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  AppSettings load() {
    return AppSettings(
      pushNotifications: _prefs.getBool(SettingsFields.pushNotifications) ?? true,
      metricHeight: _prefs.getBool(SettingsFields.metricHeight) ?? false,
      metricTemperature: _prefs.getBool(SettingsFields.metricTemperature) ?? true,
      defaultPostVisibility: _prefs.getString(SettingsFields.defaultPostVisibility) ?? Privacy.public,
    );
  }

  Future<void> save(AppSettings s) async {
    await _prefs.setBool(SettingsFields.pushNotifications, s.pushNotifications);
    await _prefs.setBool(SettingsFields.metricHeight, s.metricHeight);
    await _prefs.setBool(SettingsFields.metricTemperature, s.metricTemperature);
    await _prefs.setString(SettingsFields.defaultPostVisibility, s.defaultPostVisibility);
  }
}
