import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:url_launcher/url_launcher.dart';

class StravaConnectListItem extends StatelessWidget {
  final String userId;
  const StravaConnectListItem({super.key, required this.userId});

  Future<void> disconnectStrava(BuildContext context) async {
    final response = await Supabase.instance.client.functions.invoke('strava-disconnect');

    if (response.status != 200) {
      throw Exception('Failed to disconnect: ${response.data}');
    }
    context.read<StravaState>().getStravaConnectionStatus(userId: userId);
    // refresh whatever local state reflects the Strava connection
  }

  Future<void> connectStrava(BuildContext context) async {
    final authUrl = Uri.https('www.strava.com', '/oauth/authorize', {
      'client_id': '270263',
      'redirect_uri': 'https://pqgaczyxzxopkgyjqudk.supabase.co/functions/v1/strava-connect',
      'response_type': 'code',
      'approval_prompt': 'force',
      'scope': 'activity:read_all',
      'state': userId, // see Part 6 — sign/expire this before production
    });
    await launchUrl(authUrl, mode: LaunchMode.inAppBrowserView);

    context.read<StravaState>().getStravaConnectionStatus(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    final stravaState = context.watch<StravaState>();
    final stravaStatus = stravaState.status;
    return ListTile(
      onTap: () async {
        if (stravaStatus == StravaStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error with Strava connection. Please try again.')),
          );
          stravaState.getStravaConnectionStatus(userId: userId);
          return;
        }

        if (stravaStatus == StravaStatus.connected) {
          await disconnectStrava(context);
        } else {
          await connectStrava(context);
        }
      },
      title: stravaStatus == StravaStatus.error
          ? const Text("Error with Strava connection")
          : stravaStatus == StravaStatus.connected
              ? const Text("Disconnect from Strava")
              : const Text("Connect to Strava"),
    );
  }
}
