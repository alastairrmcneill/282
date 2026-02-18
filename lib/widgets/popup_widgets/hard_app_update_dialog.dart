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
      canPop: false, // Prevent back button dismissal
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App icon with gradient background
              SizedBox(
                width: 80,
                height: 80,
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Important Update Required",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Main message with mountain theme
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      "🏔️ Keep Bagging Those Munros!",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'ve made some important improvements to 282 that require an update. To ensure you don\'t lose any of your progress or miss out on logging your munro adventures, please update now.',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.green.shade700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Update button with mountain theme
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    context.read<Analytics>().track(AnalyticsEvent.appUpdateDialogUpdateNow);
                    String url = Platform.isIOS
                        ? "https://apps.apple.com/us/app/282/id6474512889"
                        : "https://play.google.com/store/apps/details?id=com.alastairrmcneill.TwoEightTwo";
                    try {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    } on Exception catch (error, stackTrace) {
                      context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
                      Clipboard.setData(ClipboardData(text: url));
                      showSnackBar(context, 'Copied link. Go to browser to open.');
                    }
                    // Don't close the dialog - user must update
                  },
                  child: Text(
                    'Update 282 Now',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
