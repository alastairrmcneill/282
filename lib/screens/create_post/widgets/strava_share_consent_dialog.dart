import 'package:material_ui/material_ui.dart';

/// Explicit consent before details that came from Strava are shown to anyone else (API Policy 5.13).
class StravaShareConsentDialog extends StatelessWidget {
  final String audience;
  const StravaShareConsentDialog({super.key, required this.audience});

  static Future<bool> show(BuildContext context, {required String audience}) async {
    final consented = await showDialog<bool>(
      context: context,
      builder: (_) => StravaShareConsentDialog(audience: audience),
    );
    return consented ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share details from Strava?'),
      content: Text(
        'This post was filled in from your Strava activity. Making it visible to $audience shares the date, '
        'start time and duration from that activity with them. You can edit those before posting.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep private'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Share'),
        ),
      ],
    );
  }
}
