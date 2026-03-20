import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class OutlineLinkButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final String link;
  final String? analyticsEvent;
  final Map<String, dynamic>? analyticsProps;
  const OutlineLinkButton({
    super.key,
    required this.icon,
    required this.text,
    required this.link,
    this.analyticsEvent,
    this.analyticsProps,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: Theme.of(context).outlinedButtonTheme.style!.copyWith(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              ),
            ),
        onPressed: () async {
          if (analyticsEvent != null) {
            context.read<Analytics>().track(analyticsEvent!, props: analyticsProps);
          }
          try {
            await launchUrl(
              Uri.parse(link),
            );
          } on Exception catch (error, stackTrace) {
            context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
            Clipboard.setData(ClipboardData(text: link));
            showSnackBar(context, 'Copied link. Go to browser to open.');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(width: 12),
              Expanded(child: Text(text)),
              Icon(PhosphorIconsRegular.caretRight),
            ],
          ),
        ),
      ),
    );
  }
}
