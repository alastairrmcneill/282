import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/strava/widgets/widgets.dart';
import 'package:two_eight_two/support/legal_urls.dart';

/// What we collect from Strava, how, and how to withdraw consent and delete it.
/// Shown before the Strava authorization screen (API Policy 2.1, 7.2).
class StravaDataDisclosure extends StatelessWidget {
  const StravaDataDisclosure({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StravaDisclosureItem(
          icon: PhosphorIconsRegular.listChecks,
          title: 'What 282 reads',
          body: 'Your activities (name, type, date, time, distance, elevation and route). Not activities set to '
              '"Only You". The route is only used to check it against the Munros and is never stored.',
        ),
        const StravaDisclosureItem(
          icon: PhosphorIconsRegular.arrowsClockwise,
          title: 'How',
          body: 'Strava tells 282 when you upload a new activity, and 282 reads your history once if you ask it to '
              'scan. Activities that pass a Munro are kept for at most 7 days while you review them.',
        ),
        const StravaDisclosureItem(
          icon: PhosphorIconsRegular.eyeSlash,
          title: 'Who sees it',
          body: 'Only you. Nothing from Strava is shared with other 282 users unless you choose to share a post.',
        ),
        const StravaDisclosureItem(
          icon: PhosphorIconsRegular.trash,
          title: 'Withdraw and delete',
          body: 'Disconnect any time in Settings, or revoke 282 in your Strava settings. Either way 282 deletes '
              'everything it got from Strava and confirms when it\'s done.',
        ),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
          onPressed: openPrivacyPolicyUrl,
          child: Text(
            'Read the privacy policy',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.accent,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
