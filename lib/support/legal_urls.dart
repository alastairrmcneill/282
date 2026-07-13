import 'package:url_launcher/url_launcher.dart';

const _termsUrl = 'https://282.crd.co/#terms';
const _privacyUrl = 'https://282.crd.co/#privacy';

Future<void> openTermsUrl() => launchUrl(
      Uri.parse(_termsUrl),
      mode: LaunchMode.inAppBrowserView,
    );

Future<void> openPrivacyPolicyUrl() => launchUrl(
      Uri.parse(_privacyUrl),
      mode: LaunchMode.inAppBrowserView,
    );
