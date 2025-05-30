import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/settings/screens/screens.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});
  static const String route = '${SettingsScreen.route}/legal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal'),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Terms of Service"),
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
    );
  }
}
