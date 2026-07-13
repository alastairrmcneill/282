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
    final updates = whatsNew.split(';').where((s) => s.trim().isNotEmpty).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Update Available',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Version $latestVersion is ready to download.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            if (updates.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                "What's new",
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...updates.map(
                (update) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(
                          update.trim(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              analyticsEvent: AnalyticsEvent.appUpdateDialogUpdateNow,
              onPressed: () async {
                final url = Platform.isIOS
                    ? 'https://apps.apple.com/us/app/282/id6474512889'
                    : 'https://play.google.com/store/apps/details?id=com.alastairrmcneill.TwoEightTwo';
                final logger = context.read<Logger>();
                final navigator = Navigator.of(context);
                try {
                  await launchUrl(Uri.parse(url));
                } on Exception catch (error, stackTrace) {
                  logger.error(error.toString(), stackTrace: stackTrace);
                  Clipboard.setData(ClipboardData(text: url));
                  if (context.mounted) showSnackBar(context, 'Copied link. Go to browser to open.');
                }
                navigator.pop();
              },
              child: const Text('Update Now'),
            ),
            const SizedBox(height: 8),
            SecondaryButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Not Now'),
            ),
          ],
        ),
      ),
    );
  }
}
