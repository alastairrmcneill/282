import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/strava/widgets/widgets.dart';
import 'package:two_eight_two/support/contact_support.dart';
import 'package:two_eight_two/widgets/widgets.dart';

/// Lets the user see everything 282 holds from Strava (API Policy 2.2),
/// reach support and their Strava account (2.4), and delete it (2.5).
class StravaDataScreen extends StatelessWidget {
  static const String route = '/strava_data';
  const StravaDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stravaState = context.watch<StravaState>();
    final connection = stravaState.connection;
    final isConnected = stravaState.connectionStatus == StravaConnectionStatus.connected && connection != null;
    final latestDeletion = stravaState.latestDeletion;
    final textTheme = Theme.of(context).textTheme;
    final mutedStyle = textTheme.bodyMedium?.copyWith(color: context.colors.textSubtitle);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Strava data'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isConnected) ...[
            Text('Connection', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            StravaConnectionDetails(connection: connection),
            const SizedBox(height: 24),
            Text('Activities 282 is holding', style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '282 only keeps activities that pass a Munro, and only until you review them or for 7 days, '
              'whichever comes first. Routes are never stored.',
              style: mutedStyle,
            ),
            const SizedBox(height: 12),
            if (stravaState.cachedActivities.isEmpty)
              Text("282 isn't holding any of your Strava activities right now.", style: mutedStyle)
            else
              ...stravaState.cachedActivities.map((activity) => StravaCachedActivityTile(activity: activity)),
            const SizedBox(height: 24),
            const StravaDisconnectButton(),
          ] else ...[
            Text("Strava isn't connected.", style: textTheme.titleLarge),
            const SizedBox(height: 8),
            if (latestDeletion != null)
              Text(
                'Your Strava data was permanently deleted from 282 on '
                '${DateFormat('d MMM yyyy, HH:mm').format(latestDeletion.completedAt.toLocal())}. '
                'Reference: ${latestDeletion.id}',
                style: mutedStyle,
              )
            else
              Text('282 holds no data from Strava.', style: mutedStyle),
          ],
          const SizedBox(height: 24),
          Text('Questions or requests', style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Email us to ask for a copy of your data, ask for it to be deleted, or for anything else.',
            style: mutedStyle,
          ),
          TextButton(
            style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
            onPressed: () => openSupportEmail(context, subject: '282 Strava data request'),
            child: Text(supportEmail, style: textTheme.bodyMedium?.copyWith(color: context.colors.accent)),
          ),
          const SizedBox(height: 32),
          const Center(child: PoweredByStravaLogo()),
        ],
      ),
    );
  }
}
