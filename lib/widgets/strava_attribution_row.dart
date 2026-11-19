import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/widgets.dart';

/// "View on Strava" link plus any Garmin device attribution for one activity.
class StravaAttributionRow extends StatelessWidget {
  final StravaActivity activity;
  const StravaAttributionRow({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ViewOnStravaLink(url: activity.stravaUrl),
        const Spacer(),
        GarminAttribution(activity: activity),
      ],
    );
  }
}
