import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsNewDialog extends StatefulWidget {
  final Widget child;

  const WhatsNewDialog({required this.child, Key? key}) : super(key: key);

  @override
  _WhatsNewDialogState createState() => _WhatsNewDialogState();
}

class _WhatsNewDialogState extends State<WhatsNewDialog> {
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    _checkAndShowDialog();
  }

  void _checkAndShowDialog() async {
    if (_hasShownDialog) return;
    _hasShownDialog = true;
    await SharedPreferencesService.setLastAppUpdateDialogDate("10/08/2024");

    // check if new version available
    bool isIOS = Platform.isIOS;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    print(
        "🚀 ~ file: app_update_dialog.dart:37 ~ _AppUpdaterState ~ void_checkAndShowDialog ~ appVersion: $appVersion");

    String latestAppVersion = RemoteConfigService.getString(RCFields.latestAppVersion);
    print(
        "🚀 ~ file: app_update_dialog.dart:41 ~ _AppUpdaterState ~ void_checkAndShowDialog ~ latestAppVersion: $latestAppVersion");

    bool newVersionAvailable = isVersionOlder(appVersion, latestAppVersion);
    print(
        "🚀 ~ file: app_update_dialog.dart:45 ~ _AppUpdaterState ~ void_checkAndShowDialog ~ newVersionAvailable: $newVersionAvailable");

    if (!newVersionAvailable) return;

    // Check if user saw dialog today
    String lastAppUpdateDialogDateString = await SharedPreferencesService.getLastAppUpdateDialogDate();

    DateTime lastAppUpdateDialogDate = DateFormat("dd/MM/yyyy").parse(lastAppUpdateDialogDateString);
    print(
        "🚀 ~ file: app_update_dialog.dart:53 ~ _AppUpdaterState ~ void_checkAndShowDialog ~ lastAppUpdateDialogDate: $lastAppUpdateDialogDate");
    DateTime today = DateTime.now();

    if (today.difference(lastAppUpdateDialogDate).inHours < 24) return;

    // Show dialog
    String whatsNew = RemoteConfigService.getString(RCFields.whatsNew);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSurveyDialog(context, isIOS: isIOS, appVersion: appVersion, whatsNew: whatsNew);
    });
  }

  bool isVersionOlder(String version1, String version2) {
    // returns true if version1 is older than version2

    List<int> v1 = version1.split('.').map(int.parse).toList();
    List<int> v2 = version2.split('.').map(int.parse).toList();

    // Compare each component
    for (int i = 0; i < v1.length; i++) {
      if (v1[i] < v2[i]) return true; // version1 is older
    }
    return false;
  }

  void _showSurveyDialog(
    BuildContext context, {
    required bool isIOS,
    required String appVersion,
    required String whatsNew,
  }) {
    List<String> updates = whatsNew.split(';');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          onPopInvoked: (didPop) {
            if (didPop) {
              // Mark shared prefs as seen
              print('Setting last app update dialog date ${DateFormat("dd/MM/yyyy").format(DateTime.now())}');
              // SharedPreferencesService.setLastAppUpdateDialogDate(DateFormat("dd/MM/yyyy").format(DateTime.now()));
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "What's New in $appVersion",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...updates.map(
                              (update) => Text("• $update"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
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
                      child: const Text('Update Now'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Ignore'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
