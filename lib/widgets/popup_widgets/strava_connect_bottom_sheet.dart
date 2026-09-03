import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class StravaConnectBottomSheet extends StatelessWidget {
  const StravaConnectBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    final appFlagsRepository = context.read<AppFlagsRepository>();
    await showAppBottomSheet(
      context: context,
      builder: (context) => StravaConnectBottomSheet(),
    );
    await appFlagsRepository.setShowStravaConnect(false);
  }

  Widget _featureTile(BuildContext context, IconData icon, Widget content) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: context.colors.border, width: 0.5)),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.accent.withOpacity(0.08),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon, size: 24, color: context.colors.accent),
            ),
          ),
          SizedBox(width: 12),
          Expanded(child: content),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<UserState>().currentUser?.uid ?? '';
    final munrosCount = context.read<MunroCompletionState>().completedMunroIds.length;

    return AppBottomSheet(
      padding: EdgeInsets.symmetric(horizontal: 20),
      children: [
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colors.stravaOrange,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: SvgPicture.asset('assets/icons/strava_solid_white.svg'),
            ),
            SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: context.colors.stravaBackground,
                borderRadius: BorderRadius.all(
                  Radius.circular(100),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: Text(
                  'NEW IN 282',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.colors.stravaOrange),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text('Never log a hill by hand again',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: 12),
        Text(
          'Connect Strava and every walk you record from now on gets checked against all 282 summits. When it finds one, 282 asks you to confirm it. That\'s the whole job.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        _featureTile(
            context,
            PhosphorIconsRegular.lockSimple,
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  TextSpan(text: 'Your '),
                  TextSpan(
                    text: '$munrosCount logged Munro${munrosCount == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' stay exactly as they are'),
                ],
              ),
            )),
        SizedBox(height: 12),
        _featureTile(
          context,
          PhosphorIconsRegular.checkCircle,
          Text(
            'Nothing is ever ticked off without you confirming it',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        SizedBox(height: 24),
        CtaButton(
          height: 56,
          backgroundColor: context.colors.stravaOrange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/strava_solid_white.svg', height: 24),
              SizedBox(width: 12),
              Text('Connect with Strava'),
            ],
          ),
          onPressed: () async {
            final authUrl = Uri.https('www.strava.com', '/oauth/authorize', {
              'client_id': '270263',
              'redirect_uri': 'https://pqgaczyxzxopkgyjqudk.supabase.co/functions/v1/strava-connect',
              'response_type': 'code',
              'approval_prompt': 'force',
              'scope': 'activity:read_all',
              'state': userId,
            });
            await launchUrl(authUrl, mode: LaunchMode.inAppBrowserView);

            final connectionStatus = await context.read<StravaState>().getStravaConnectionStatus(userId: userId);
            print("🎯 ~ StravaConnectBottomSheet ~ build ~ connectionStatus: $connectionStatus");

            if (connectionStatus == StravaConnectionStatus.connected) {
              Navigator.of(context).pushReplacementNamed(StravaConnectedScreen.route);
            } else {}
          },
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Not just now',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.colors.textMuted, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
