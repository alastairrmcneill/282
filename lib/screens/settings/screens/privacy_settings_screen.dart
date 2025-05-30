import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class PrivacySettingsScreen extends StatelessWidget {
  static const String route = '${SettingsScreen.route}/privacy';
  PrivacySettingsScreen({super.key});

  final List<String> _postVisibilityOptions = [
    Privacy.public,
    Privacy.friends,
    Privacy.private,
  ];

  final List<String> _profileVisibilityOptions = [
    Privacy.public,
    Privacy.hidden,
  ];

  @override
  Widget build(BuildContext context) {
    SettingsState settingsState = Provider.of<SettingsState>(context);
    UserState userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Default Post Visibility'),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: settingsState.defaultPostVisibility,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    settingsState.setDefaultPostVisibility = newValue;
                    SettingsSerivce.setStringSetting(
                      settingName: SettingsFields.defaultPostVisibility,
                      value: newValue,
                    );
                  }
                },
                items: _postVisibilityOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value.capitalize(),
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Profile Visibility'),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: userState.currentUser?.profileVisibility ?? Privacy.public,
                onChanged: (String? newValue) {
                  print(newValue);
                  if (newValue != null) {
                    UserService.updateProfileVisibility(context, newValue);
                  }
                },
                items: _profileVisibilityOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value.capitalize(),
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
