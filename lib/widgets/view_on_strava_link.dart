import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

/// Link back to the original data on Strava. Text and styling are set by the Brand Guidelines.
class ViewOnStravaLink extends StatelessWidget {
  final Uri url;
  const ViewOnStravaLink({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(url, mode: LaunchMode.externalApplication),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          'View on Strava',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.colors.stravaOrange,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
