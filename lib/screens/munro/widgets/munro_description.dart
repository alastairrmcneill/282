import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroDescription extends StatelessWidget {
  const MunroDescription({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    return RichText(
      text: TextSpan(
        text: "${munroState.selectedMunro?.description ?? ""} ",
        style: const TextStyle(color: Colors.black, fontFamily: "NotoSans"),
        children: <TextSpan>[
          TextSpan(
            text: 'Read more.',
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                await launchUrl(
                  Uri.parse(munroState.selectedMunro?.link ?? ""),
                );
              },
          ),
        ],
      ),
    );
  }
}
