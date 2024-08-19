import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class SettingsSerivce {
  static Future loadSettings(BuildContext context) async {
    SettingsState settingsState = Provider.of<SettingsState>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    settingsState.setEnablePushNotifications = prefs.getBool(SettingsFields.pushNotifications) ?? true;
    settingsState.setMetricHeight = prefs.getBool(SettingsFields.metricHeight) ?? false;
    settingsState.setMetricTemperature = prefs.getBool(SettingsFields.metricTemperature) ?? true;
    settingsState.setDefaultPostVisibility = prefs.getString(SettingsFields.defaultPostVisibility) ?? Privacy.public;
    print(
        "prefs.getString(SettingsFields.defaultPostVisibility): ${prefs.getString(SettingsFields.defaultPostVisibility)}");
    print("SettingsState.defaultPostVisibility: ${settingsState.defaultPostVisibility}");
  }

  // Read bool setting
  static Future<bool> getBoolSetting({required String settingName}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(settingName) ?? false;
  }

  // Set bool setting
  static Future setBoolSetting({required String settingName, required bool value}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(settingName, value);
  } // Read bool setting

  static Future<String> getStringSetting({required String settingName}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(settingName) ?? "";
  }

  // Set String setting
  static Future setStringSetting({required String settingName, required String value}) async {
    print("Setting $settingName to $value");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(settingName, value);
  }
}

class SettingsFields {
  static String pushNotifications = "push_notifications";
  static String metricHeight = "metric_height";
  static String metricTemperature = "metric_temperature";
  static String defaultPostVisibility = "default_post_visibility";
}
