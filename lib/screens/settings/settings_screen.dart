import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/logging/logging.dart';

import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/settings/screens/screens.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/settings/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';
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
                leading: const Icon(PhosphorIconsRegular.user, color: MyColors.accentColor),
                trailing: const Icon(Icons.chevron_right, color: MyColors.mutedText),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(PrivacySettingsScreen.route);
                },
                title: const Text("Privacy"),
                leading: const Icon(PhosphorIconsRegular.shield, color: MyColors.accentColor),
                trailing: const Icon(Icons.chevron_right, color: MyColors.mutedText),
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
                leading: const Icon(PhosphorIconsRegular.bell, color: MyColors.accentColor),
                trailing: const Icon(Icons.chevron_right, color: MyColors.mutedText),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed(UnitsSettingsScreen.route);
                },
                title: const Text("Units"),
                leading: const Icon(PhosphorIconsRegular.ruler, color: MyColors.accentColor),
                trailing: const Icon(Icons.chevron_right, color: MyColors.mutedText),
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
                leading: const Icon(PhosphorIconsRegular.listChecks, color: MyColors.accentColor),
                trailing: const Icon(Icons.chevron_right, color: MyColors.mutedText),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Support',
            children: [
              ListTile(
                onTap: () async {
                  try {
                    await launchUrl(
                      Uri.parse('mailto:alastair.r.mcneill@gmail.com?subject=282%20Feedback'),
                    );
                  } on Exception catch (error, stackTrace) {
                    context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
                    Clipboard.setData(ClipboardData(text: "alastair.r.mcneill@gmail.com"));
                    showSnackBar(context, 'Copied email address. Go to email app to send.');
                  }
                },
                title: const Text("Email us"),
                leading: const Icon(PhosphorIconsRegular.envelopeSimple, color: MyColors.accentColor),
                trailing: const Icon(Icons.chevron_right, color: MyColors.mutedText),
              ),
              ListTile(
                onTap: () async {
                  String url = Platform.isIOS
                      ? "https://apps.apple.com/us/app/282/id6474512889"
                      : "https://play.google.com/store/apps/details?id=com.alastairrmcneill.TwoEightTwo";
                  try {
                    await launchUrl(
                      Uri.parse(url),
                    );
                  } on Exception catch (error, stackTrace) {
                    context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
                    Clipboard.setData(ClipboardData(text: url));
                    showSnackBar(context, 'Copied link. Go to browser to open.');
                  }
                },
                title: const Text("Rate 282"),
                leading: const Icon(PhosphorIconsRegular.star, color: MyColors.accentColor),
                trailing: const Icon(Icons.chevron_right, color: MyColors.mutedText),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Legal',
            children: [
              ListTile(
                title: const Text("Terms of Service"),
                leading: const Icon(PhosphorIconsRegular.fileText, color: MyColors.accentColor),
                trailing: const Icon(Icons.chevron_right, color: MyColors.mutedText),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    DocumentScreen.route,
                    arguments: DocumentScreenArgs(
                      title: 'Terms of Service',
                      mdFileName: 'assets/documents/terms_and_conditions.md',
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text("Privacy Policy"),
                leading: const Icon(PhosphorIconsRegular.shield, color: MyColors.accentColor),
                trailing: const Icon(Icons.chevron_right, color: MyColors.mutedText),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    DocumentScreen.route,
                    arguments: DocumentScreenArgs(
                      title: 'Privacy Policy',
                      mdFileName: 'assets/documents/privacy_policy.md',
                    ),
                  );
                },
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
                leading: const Icon(PhosphorIconsRegular.signOut, color: MyColors.accentColor),
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
                leading: const Icon(PhosphorIconsRegular.trash, color: Colors.red),
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
                      "282 v${snapshot.data!.version} (${snapshot.data!.buildNumber})",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: MyColors.mutedText),
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
