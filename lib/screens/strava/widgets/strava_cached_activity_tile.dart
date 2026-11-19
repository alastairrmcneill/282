import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaCachedActivityTile extends StatelessWidget {
  final StravaActivity activity;
  const StravaCachedActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM yyyy').format(activity.startDate);
    final expiresAt = activity.expiresAt;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.name, style: Theme.of(context).textTheme.titleMedium),
            Text(
              '${activity.activityType} · $date',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textSubtitle),
            ),
            if (expiresAt != null)
              Text(
                'Deleted from 282 by ${DateFormat('d MMM').format(expiresAt.toLocal())}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
              ),
            StravaAttributionRow(activity: activity),
          ],
        ),
      ),
    );
  }
}
