import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

const supportEmail = 'alastair.r.mcneill@gmail.com';

Future<void> openSupportEmail(BuildContext context, {String subject = '282 Feedback', String? prefill}) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final devicePlugin = DeviceInfoPlugin();
    String deviceModel = 'Unknown';
    String osVersion = 'Unknown';

    if (Platform.isIOS) {
      final iosInfo = await devicePlugin.iosInfo;
      deviceModel = iosInfo.utsname.machine;
      osVersion = 'iOS ${iosInfo.systemVersion}';
    } else if (Platform.isAndroid) {
      final androidInfo = await devicePlugin.androidInfo;
      deviceModel = androidInfo.model;
      osVersion = 'Android ${androidInfo.version.release}';
    }

    if (!context.mounted) return;
    final userId = context.read<UserState>().currentUser?.uid ?? 'Unknown';
    final now = DateTime.now().toUtc();
    final body = '${prefill ?? '[Write your message here]'}\n\n\n---\n'
        'App: v${packageInfo.version} (${packageInfo.buildNumber})\n'
        'Date: ${now.toIso8601String().split('.').first} UTC\n'
        'User ID: $userId\n\n'
        'Device: $deviceModel\n'
        'OS: $osVersion';

    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    await launchUrl(uri);
  } on Exception catch (error, stackTrace) {
    if (!context.mounted) return;
    context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
    Clipboard.setData(const ClipboardData(text: supportEmail));
    showSnackBar(context, 'Copied email address. Go to email app to send.');
  }
}
