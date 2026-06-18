import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class HardUpdateDialog extends StatelessWidget {
  HardUpdateDialog({super.key});

  final bool isIOS = Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/app_icon.png',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                'Update Required',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'A new version of 282 is available. Please update to continue.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                analyticsEvent: AnalyticsEvent.appUpdateDialogUpdateNow,
                onPressed: () async {
                  final url = Platform.isIOS
                      ? 'https://apps.apple.com/us/app/282/id6474512889'
                      : 'https://play.google.com/store/apps/details?id=com.alastairrmcneill.TwoEightTwo';
                  final logger = context.read<Logger>();
                  try {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } on Exception catch (error, stackTrace) {
                    logger.error(error.toString(), stackTrace: stackTrace);
                    Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) showSnackBar(context, 'Copied link. Go to browser to open.');
                  }
                },
                child: const Text('Update Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
