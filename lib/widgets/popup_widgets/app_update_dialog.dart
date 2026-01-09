import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SoftUpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String whatsNew;

  SoftUpdateDialog({
    super.key,
    required this.currentVersion,
    required this.latestVersion,
    required this.whatsNew,
  });

  final bool isIOS = Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    List<String> updates = whatsNew.split(';');
    return Dialog(
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
                  context.read<Analytics>().track(AnalyticsEvent.appUpdateDialogUpdateNow);
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

                  Navigator.of(context).pop();
                },
                child: const Text('Update Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
