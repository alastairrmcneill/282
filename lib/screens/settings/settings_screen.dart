import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/settings/screens/screens.dart';
import 'package:two_eight_two/support/legal_urls.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/settings/widgets/widgets.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  static const String route = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserState>().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          SettingsGroup(
            title: 'Account',
            children: [
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(EditProfileScreen.route);
                },
                title: const Text("Edit Profile"),
                leading: Icon(PhosphorIconsRegular.user, color: context.colors.accent),
                trailing: Icon(Icons.chevron_right, color: context.colors.textMuted),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(PrivacySettingsScreen.route);
                },
                title: const Text("Privacy"),
                leading: Icon(PhosphorIconsRegular.shield, color: context.colors.accent),
                trailing: Icon(Icons.chevron_right, color: context.colors.textMuted),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Preferences',
            children: [
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(NotificationSettingsScreen.route);
                },
                title: const Text("Push Notifications"),
                leading: Icon(PhosphorIconsRegular.bell, color: context.colors.accent),
                trailing: Icon(Icons.chevron_right, color: context.colors.textMuted),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(UnitsSettingsScreen.route);
                },
                title: const Text("Units"),
                leading: Icon(PhosphorIconsRegular.ruler, color: context.colors.accent),
                trailing: Icon(Icons.chevron_right, color: context.colors.textMuted),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(AppearanceSettingsScreen.route);
                },
                title: const Text("Appearance"),
                leading: Icon(PhosphorIconsRegular.moon, color: context.colors.accent),
                trailing: Icon(Icons.chevron_right, color: context.colors.textMuted),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Munro Management',
            children: [
              ListTile(
                onTap: () {
                  BulkMunroUpdateState bulkMunroUpdateState = context.read<BulkMunroUpdateState>();
                  MunroCompletionState munroCompletionState = context.read<MunroCompletionState>();
                  MunroState munroState = context.read<MunroState>();

                  bulkMunroUpdateState.setStartingBulkMunroUpdateList = munroCompletionState.munroCompletions;
                  munroState.clearFilterAndSorting();

                  Navigator.of(context).pushNamed(BulkMunroUpdateScreen.route);
                },
                title: Text('Log Past Munros'),
                leading: Icon(PhosphorIconsRegular.listChecks, color: context.colors.accent),
                trailing: Icon(Icons.chevron_right, color: context.colors.textMuted),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Support',
            children: [
              ListTile(
                onTap: () async {
                  try {
                    final packageInfo = await PackageInfo.fromPlatform();
                    final devicePlugin = DeviceInfoPlugin();
                    String deviceModel = 'Unknown';
                    String osVersion = 'Unknown';

                    if (Platform.isIOS) {
                      final iosInfo = await devicePlugin.iosInfo;
                      deviceModel = iosInfo.utsname.machine;
                      osVersion = 'iOS ${iosInfo.systemVersion}';
                    } else if (Platform.isAndroid) {
                      final androidInfo = await devicePlugin.androidInfo;
                      deviceModel = androidInfo.model;
                      osVersion = 'Android ${androidInfo.version.release}';
                    }

                    if (!context.mounted) return;
                    final userId = context.read<UserState>().currentUser?.uid ?? 'Unknown';
                    final now = DateTime.now().toUtc();
                    final body = '[Write your message here]\n\n\n---\n'
                        'App: v${packageInfo.version} (${packageInfo.buildNumber})\n'
                        'Date: ${now.toIso8601String().split('.').first} UTC\n'
                        'User ID: $userId\n\n'
                        'Device: $deviceModel\n'
                        'OS: $osVersion';

                    final uri = Uri(
                      scheme: 'mailto',
                      path: 'alastair.r.mcneill@gmail.com',
                      query: 'subject=${Uri.encodeComponent('282 Feedback')}&body=${Uri.encodeComponent(body)}',
                    );

                    await launchUrl(uri);
                  } on Exception catch (error, stackTrace) {
                    if (!context.mounted) return;
                    context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
                    Clipboard.setData(ClipboardData(text: "alastair.r.mcneill@gmail.com"));
                    showSnackBar(context, 'Copied email address. Go to email app to send.');
                  }
                },
                title: const Text("Email us"),
                leading: Icon(PhosphorIconsRegular.envelopeSimple, color: context.colors.accent),
                trailing: Icon(Icons.chevron_right, color: context.colors.textMuted),
              ),
              ListTile(
                onTap: () async {
                  String url = Platform.isIOS
                      ? "https://apps.apple.com/us/app/282/id6474512889"
                      : "https://play.google.com/store/apps/details?id=com.alastairrmcneill.TwoEightTwo";
                  try {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  } on Exception catch (error, stackTrace) {
                    context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
                    Clipboard.setData(ClipboardData(text: url));
                    showSnackBar(context, 'Copied link. Go to browser to open.');
                  }
                },
                title: const Text("Rate 282"),
                leading: Icon(PhosphorIconsRegular.star, color: context.colors.accent),
                trailing: Icon(Icons.chevron_right, color: context.colors.textMuted),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Legal',
            children: [
              ListTile(
                title: const Text("Terms of Service"),
                leading: Icon(PhosphorIconsRegular.fileText, color: context.colors.accent),
                trailing: Icon(Icons.chevron_right, color: context.colors.textMuted),
                onTap: () { openTermsUrl(); },
              ),
              ListTile(
                title: const Text("Privacy Policy"),
                leading: Icon(PhosphorIconsRegular.shield, color: context.colors.accent),
                trailing: Icon(Icons.chevron_right, color: context.colors.textMuted),
                onTap: () { openPrivacyPolicyUrl(); },
              ),
            ],
          ),
          SettingsGroup(
            children: [
              ListTile(
                onTap: () async {
                  await context.read<AuthState>().signOut().then((_) {
                    context.read<MunroCompletionState>().reset();
                    context.read<SavedListState>().reset();
                    Navigator.of(context).pushReplacementNamed(HomeScreen.route);
                  });
                },
                title: const Text("Sign out"),
                leading: Icon(PhosphorIconsRegular.signOut, color: context.colors.accent),
              ),
              ListTile(
                onTap: () async {
                  showConfirmationDialog(
                    context,
                    message: "Are you sure you want to delete account and all associated data?",
                    onConfirm: () async {
                      await context.read<AuthState>().deleteUser(user!).then((_) {
                        context.read<MunroCompletionState>().reset();
                        context.read<SavedListState>().reset();
                        Navigator.of(context).pushReplacementNamed(HomeScreen.route);
                      });
                    },
                  );
                },
                title: const Text(
                  'Delete account',
                  style: TextStyle(color: Colors.red),
                ),
                leading: Icon(PhosphorIconsRegular.trash, color: Colors.red),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Center(
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      "v${snapshot.data!.version} (${snapshot.data!.buildNumber})",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.colors.textMuted),
                    );
                  } else {
                    return LoadingWidget(text: "Loading app information...");
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
