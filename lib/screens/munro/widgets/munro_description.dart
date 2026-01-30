import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroDescription extends StatelessWidget {
  const MunroDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final munroDetailState = context.watch<MunroDetailState>();
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
            text: "${munroDetailState.selectedMunro?.description ?? ""} ",
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
                    context.read<Analytics>().track(AnalyticsEvent.walkHighlandsMunroLinkClicked, props: {
                      AnalyticsProp.munroId: munroDetailState.selectedMunro?.id ?? 0,
                      AnalyticsProp.munroName: munroDetailState.selectedMunro?.name ?? "",
                    });
                    try {
                      await launchUrl(
                        Uri.parse(munroDetailState.selectedMunro?.link ?? ""),
                      );
                    } on Exception catch (error, stackTrace) {
                      context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
                      Clipboard.setData(ClipboardData(text: munroDetailState.selectedMunro?.link ?? ""));
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
