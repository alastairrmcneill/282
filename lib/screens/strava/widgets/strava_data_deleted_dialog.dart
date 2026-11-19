import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/models/models.dart';

/// Written confirmation that Strava Data was deleted (API Policy 2.5).
class StravaDataDeletedDialog extends StatelessWidget {
  final StravaDataDeletion deletion;
  const StravaDataDeletedDialog({super.key, required this.deletion});

  static Future<void> show(BuildContext context, {required StravaDataDeletion deletion}) {
    return showDialog(
      context: context,
      builder: (_) => StravaDataDeletedDialog(deletion: deletion),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedAt = DateFormat('d MMM yyyy, HH:mm').format(deletion.completedAt.toLocal());
    return AlertDialog(
      title: const Text('Strava disconnected'),
      content: Text(
        'Your Strava data was permanently deleted from 282 on $completedAt, and 282 no longer has access to your '
        'Strava account.\n\n'
        'Munros you already confirmed stay on your map because you logged them.\n\n'
        'Reference: ${deletion.id}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
