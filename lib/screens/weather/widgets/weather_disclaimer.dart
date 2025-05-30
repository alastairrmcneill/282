import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class WeatherDisclaimer extends StatelessWidget {
  const WeatherDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
        children: [
          const TextSpan(text: '⚠️ Disclaimer\n'),
          const TextSpan(
            text:
                'The weather on munros can change very quickly and very dramatically. Always be prepared with the right gear and take caution. For a more detailed weather forecast, click here: ',
          ),
          TextSpan(
            text: 'Met Office Weather',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                AnalyticsService.logEvent(
                  name: "Weather Met Office Link Clicked",
                  parameters: {},
                );
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
    );
  }
}
