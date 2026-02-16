import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AboutScreen extends StatelessWidget {
  static const String route = '${SettingsScreen.route}/about';
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: false,
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: [
                ListTile(
                  title: const Text("Version"),
                  subtitle: Text("${snapshot.data!.version} (${snapshot.data!.buildNumber})"),
                ),
              ],
            );
          } else {
            return LoadingWidget(text: "Loading app information...");
          }
        },
      ),
    );
  }
}
