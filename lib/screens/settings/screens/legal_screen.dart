import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

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
              showDocumentDialog(context, mdFileName: 'assets/documents/terms_and_conditions.md');
            },
          ),
          ListTile(
            title: const Text("Privacy Policy"),
            onTap: () {
              showDocumentDialog(context, mdFileName: 'assets/documents/privacy_policy.md');
            },
          ),
        ],
      ),
    );
  }
}
