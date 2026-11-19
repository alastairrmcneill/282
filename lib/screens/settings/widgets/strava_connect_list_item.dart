import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/strava/widgets/widgets.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaConnectListItem extends StatelessWidget {
  final String userId;
  const StravaConnectListItem({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final stravaState = context.watch<StravaState>();
    final stravaStatus = stravaState.connectionStatus;

    if (stravaStatus == StravaConnectionStatus.error) {
      return ListTile(
        title: const Text("Error with Strava connection"),
        subtitle: const Text('Tap to try again'),
        onTap: () => stravaState.getStravaConnectionStatus(userId: userId),
      );
    }

    if (stravaStatus != StravaConnectionStatus.connected) {
      return ListTile(
        title: const Text("Connect to Strava"),
        onTap: () => StravaConnectBottomSheet.show(context),
      );
    }

    return Column(
      children: [
        ListTile(
          title: const Text("Your Strava data"),
          subtitle: const Text('See what 282 holds from Strava'),
          onTap: () => Navigator.of(context).pushNamed(StravaDataScreen.route),
        ),
        ListTile(
          title: const Text("Disconnect from Strava"),
          subtitle: const Text('Deletes all your Strava data from 282'),
          onTap: () => StravaDisconnectButton.confirmAndDisconnect(context),
        ),
      ],
    );
  }
}
