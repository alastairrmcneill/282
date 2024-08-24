import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateDialog extends StatefulWidget {
  final Widget child;

  const AppUpdateDialog({required this.child, Key? key}) : super(key: key);

  @override
  _AppUpdateDialogState createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  bool _hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    _checkAndShowDialog();
  }

  void _checkAndShowDialog() async {
    if (_hasShownDialog) return;
    _hasShownDialog = true;

    // check if new version available
    bool isIOS = Platform.isIOS;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;

    String latestAppVersion = RemoteConfigService.getString(RCFields.latestAppVersion);

    bool newVersionAvailable = isVersionOlder(appVersion, latestAppVersion);

    if (!newVersionAvailable) return;

    // Check if user saw dialog today
    String lastAppUpdateDialogDateString = await SharedPreferencesService.getLastAppUpdateDialogDate();

    DateTime lastAppUpdateDialogDate = DateFormat("dd/MM/yyyy").parse(lastAppUpdateDialogDateString);
    DateTime today = DateTime.now();

    if (today.difference(lastAppUpdateDialogDate).inDays < 1) return;

    // Show dialog
    String whatsNew = RemoteConfigService.getString(RCFields.whatsNew);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSurveyDialog(
        context,
        isIOS: isIOS,
        currentVersion: appVersion,
        latestVersion: latestAppVersion,
        whatsNew: whatsNew,
      );
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
    required String currentVersion,
    required String latestVersion,
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
              SharedPreferencesService.setLastAppUpdateDialogDate(DateFormat("dd/MM/yyyy").format(DateTime.now()));
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.5,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Update app?",
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'A new version 282 is available! Version $latestVersion is now available for download. (You have version $currentVersion)',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, height: 1.8),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "What's new in $latestVersion:",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 13, fontWeight: FontWeight.bold, height: 1.8),
                            ),
                            const SizedBox(height: 5),
                            ...updates.map(
                              (update) => Text(
                                "• $update",
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, height: 1.8),
                              ),
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

                        Navigator.of(context).pop();
                      },
                      child: const Text('Update Now'),
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
