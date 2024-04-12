import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class WeatherInfoDialog extends StatelessWidget {
  final String link;
  const WeatherInfoDialog({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _showIOSDialog(context) : _showAndroidDialog(context);
  }

  AlertDialog _showAndroidDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('⚠️ Warning'),
      content: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black),
          children: [
            const TextSpan(
              text:
                  'The weather on munros can change very quickly and very dramatically. Always be prepared with the right gear and take caution. For a more detailed weather forecast, click here:\n',
            ),
            TextSpan(
              text: 'Met Office Weather',
              style: const TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  try {
                    await launchUrl(
                      Uri.parse('https://www.metoffice.gov.uk/'),
                    );
                  } on Exception catch (error, stackTrace) {
                    Log.error(error.toString(), stackTrace: stackTrace);
                    Clipboard.setData(ClipboardData(text: 'https://www.metoffice.gov.uk/'));
                    showSnackBar(context, 'Copied link. Go to browser to open.');
                  }
                },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Ok',
            style: TextStyle(decoration: TextDecoration.none),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  CupertinoAlertDialog _showIOSDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('⚠️ Warning'),
      content: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            const TextSpan(
              text:
                  'The weather on munros can change very quickly and very dramatically. Always be prepared with the right gear and take caution. For a more detailed weather forecast, click here:\n',
            ),
            TextSpan(
              text: 'Met Office Weather',
              style: const TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  try {
                    await launchUrl(
                      Uri.parse('https://www.metoffice.gov.uk/'),
                    );
                  } on Exception catch (error, stackTrace) {
                    Log.error(error.toString(), stackTrace: stackTrace);
                    Clipboard.setData(ClipboardData(text: 'https://www.metoffice.gov.uk/'));
                    showSnackBar(context, 'Copied link. Go to browser to open.');
                  }
                },
            ),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text(
            'Confirm',
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

showWeatherInfoDialog(
  BuildContext context, {
  required String link,
}) {
  showDialog(
    context: context,
    builder: (context) => WeatherInfoDialog(
      link: link,
    ),
  );
}
