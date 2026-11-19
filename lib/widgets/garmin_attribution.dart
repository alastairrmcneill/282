import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';

/// Device attribution required when showing data recorded on a Garmin device (API Policy 4.4).
class GarminAttribution extends StatelessWidget {
  final StravaActivity activity;
  const GarminAttribution({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    if (!activity.isGarminRecorded) return const SizedBox.shrink();
    return Text(
      activity.deviceName!,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
    );
  }
}
