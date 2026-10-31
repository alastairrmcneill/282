import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/support/legal_urls.dart';

class ConsentText extends StatelessWidget {
  final String initialText;
  final String termsText;
  final String privacyPolicyText;
  final Color? textColor;
  const ConsentText({
    super.key,
    this.textColor,
    this.initialText = "By continuing you agree to our ",
    this.termsText = "Terms",
    this.privacyPolicyText = "Privacy Policy",
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: initialText,
        style: Theme.of(context)
            .textTheme
            .labelSmall!
            .copyWith(color: textColor ?? Theme.of(context).textTheme.bodySmall!.color?.withOpacity(0.8)),
        children: [
          TextSpan(
            text: termsText,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              color: textColor ?? Theme.of(context).textTheme.bodySmall!.color,
              decorationColor: textColor ?? Theme.of(context).textTheme.bodySmall!.color,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                openTermsUrl();
              },
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: privacyPolicyText,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              color: textColor ?? Theme.of(context).textTheme.bodySmall!.color,
              decorationColor: textColor ?? Theme.of(context).textTheme.bodySmall!.color,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                openPrivacyPolicyUrl();
              },
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }
}
