import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class SettingsSerivce {
  static Future loadSettings(BuildContext context) async {
    SettingsState settingsState = Provider.of<SettingsState>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    settingsState.setEnablePushNotifications = prefs.getBool(SettingsFields.pushNotifications) ?? true;
  }

  // Read specific setting

  // Set specific setting
  static Future setBoolSetting({required String settingName, required bool value}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(settingName, value);
  }
}

class SettingsFields {
  static String pushNotifications = "push_notifications";
}
