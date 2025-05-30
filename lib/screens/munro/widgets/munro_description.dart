import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroDescription extends StatelessWidget {
  const MunroDescription({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            text: "${munroState.selectedMunro?.description ?? ""} ",
            style: Theme.of(context).textTheme.bodyMedium,
            children: <TextSpan>[
              TextSpan(
                text: 'Read more.',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    AnalyticsService.logEvent(
                      name: "Walk Highlands Munro Link Clicked",
                      parameters: {
                        "munro_id": munroState.selectedMunro?.id ?? "",
                        "munro_name": munroState.selectedMunro?.name ?? "",
                      },
                    );
                    try {
                      await launchUrl(
                        Uri.parse(munroState.selectedMunro?.link ?? ""),
                      );
                    } on Exception catch (error, stackTrace) {
                      Log.error(error.toString(), stackTrace: stackTrace);
                      Clipboard.setData(ClipboardData(text: munroState.selectedMunro?.link ?? ""));
                      showSnackBar(context, 'Copied link. Go to browser to open.');
                    }
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
