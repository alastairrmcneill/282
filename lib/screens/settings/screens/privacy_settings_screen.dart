import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PrivacySettingsScreen extends StatelessWidget {
  static const String route = '${SettingsScreen.route}/privacy';
  PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    final userState = context.watch<UserState>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Text('Post visibility', style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Control who can view your posts.',
              style: textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  OptionListTile(
                      title: 'Public',
                      subtitle: 'Anyone can view your posts.',
                      value: Privacy.public,
                      groupValue: settingsState.defaultPostVisibility,
                      onChanged: (value) {
                        settingsState.setDefaultPostVisibility(value);
                      }),
                  Divider(
                    endIndent: 15,
                    indent: 15,
                  ),
                  OptionListTile(
                      title: 'Friends',
                      subtitle: 'Only people you follow can view your posts',
                      value: Privacy.friends,
                      groupValue: settingsState.defaultPostVisibility,
                      onChanged: (value) {
                        settingsState.setDefaultPostVisibility(value);
                      }),
                  Divider(
                    endIndent: 15,
                    indent: 15,
                  ),
                  OptionListTile(
                      title: 'Private',
                      subtitle: 'Only you can view your posts.',
                      value: Privacy.private,
                      groupValue: settingsState.defaultPostVisibility,
                      onChanged: (value) {
                        settingsState.setDefaultPostVisibility(value);
                      }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Profile visibility', style: textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Control who can view your profile.',
              style: textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
            ),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  OptionListTile(
                      title: 'Public',
                      subtitle: 'Anyone can view your profile.',
                      value: Privacy.public,
                      groupValue: userState.currentUser?.profileVisibility,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<UserState>().updateProfileVisibility(value);
                        }
                      }),
                  Divider(
                    endIndent: 15,
                    indent: 15,
                  ),
                  OptionListTile(
                      title: 'Hidden',
                      subtitle: 'Only you can view your profile.',
                      value: Privacy.hidden,
                      groupValue: userState.currentUser?.profileVisibility,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<UserState>().updateProfileVisibility(value);
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
