import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class StravaDisconnectConfirmDialog extends StatelessWidget {
  const StravaDisconnectConfirmDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const StravaDisconnectConfirmDialog(),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Disconnect Strava?'),
      content: const Text(
        '282 will stop checking your walks and permanently delete everything it holds from Strava. '
        'Munros you already confirmed stay on your map.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Disconnect', style: TextStyle(color: context.colors.warning)),
        ),
      ],
    );
  }
}
