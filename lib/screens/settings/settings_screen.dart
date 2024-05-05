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
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            title: const Text("Edit Profile"),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MunroChallengeListScreen()),
              );
            },
            title: const Text("Munro Challenges"),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AchievementListScreen()),
              );
            },
            title: const Text("Achievements"),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              );
            },
            title: const Text("Push Notifications"),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UnitsSettingsScreen()),
              );
            },
            title: const Text("Units"),
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
              munroState.setBulkMunroUpdateFilterString = "";

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BulkMunroUpdateScreen()),
              );
            },
            title: Text('Bulk Munro Update'),
          ),
          ListTile(
            onTap: () async {
              FirebaseMessaging _messaging = FirebaseMessaging.instance;
              String? token = await _messaging.getToken();
              print(token);
            },
            title: const Text("FCM"),
          ),
          ListTile(
            onTap: () async {
              String url = Platform.isIOS
                  ? "https://testflight.apple.com/join/CsiMRS87"
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LegalScreen()),
              );
            },
            title: const Text("Legal"),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
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
