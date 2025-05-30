import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/settings/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  static const String route = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    FlavorState flavorState = Provider.of<FlavorState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(EditProfileScreen.route);
            },
            title: const Text("Edit Profile"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(MunroChallengeListScreen.route);
            },
            title: const Text("Munro Challenges"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(AchievementListScreen.route);
            },
            title: const Text("Achievements"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(NotificationSettingsScreen.route);
            },
            title: const Text("Push Notifications"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(UnitsSettingsScreen.route);
            },
            title: const Text("Units"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(PrivacySettingsScreen.route);
            },
            title: const Text("Privacy"),
          ),
          ListTile(
            onTap: () async {
              try {
                await launchUrl(
                  Uri.parse('mailto:alastair.r.mcneill@gmail.com?subject=282%20Feedback'),
                );
              } on Exception catch (error, stackTrace) {
                Log.error(error.toString(), stackTrace: stackTrace);
                Clipboard.setData(ClipboardData(text: "alastair.r.mcneill@gmail.com"));
                showSnackBar(context, 'Copied email address. Go to email app to send.');
              }
            },
            title: const Text("Email us"),
          ),
          ListTile(
            onTap: () {
              BulkMunroUpdateState bulkMunroUpdateState = Provider.of<BulkMunroUpdateState>(context, listen: false);
              UserState userState = Provider.of<UserState>(context, listen: false);
              MunroState munroState = Provider.of<MunroState>(context, listen: false);

              bulkMunroUpdateState.setBulkMunroUpdateList = userState.currentUser!.personalMunroData!;
              munroState.clearFilterAndSorting();

              Navigator.of(context).pushNamed(BulkMunroUpdateScreen.route);
            },
            title: Text('Bulk Munro Update'),
          ),
          flavorState.flavor == "Development"
              ? ListTile(
                  onTap: () async {
                    FirebaseMessaging _messaging = FirebaseMessaging.instance;
                    String? token = await _messaging.getToken();
                    print(token);
                  },
                  title: const Text("FCM"),
                )
              : const SizedBox(),
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
                Log.error(error.toString(), stackTrace: stackTrace);
                Clipboard.setData(ClipboardData(text: url));
                showSnackBar(context, 'Copied link. Go to browser to open.');
              }
            },
            title: const Text("Rate 282"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(LegalScreen.route);
            },
            title: const Text("Legal"),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(AboutScreen.route);
            },
            title: const Text("About"),
          ),
          ListTile(
            onTap: () async {
              await AuthService.signOut(context);
            },
            title: const Text("Sign out"),
          ),
          ListTile(
            onTap: () async {
              showConfirmationDialog(
                context,
                message: "Are you sure you want to delete account and all associated data?",
                onConfirm: () async {
                  await AuthService.deleteUser(context, appUser: user!);
                },
              );
            },
            title: const Text(
              'Delete account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
