import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/profile/screens/screens.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/services/auth_service.dart';
import 'package:two_eight_two/general/widgets/widgets.dart';

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
            onTap: () async {
              await AuthService.signOut(context);
            },
            title: const Text("Sign out"),
          ),
          ListTile(
            onTap: () async {
              showConfirmationDialog(
                context,
                message:
                    "Are you sure you want to delete account and all associated data?",
                onConfirm: () async {
                  await AuthService.deleteUserFromUid(context, uid: user!.uid!);
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
