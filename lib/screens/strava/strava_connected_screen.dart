import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/strava/strava_connected_colors.dart';
import 'package:two_eight_two/screens/strava/widgets/widgets.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaConnectedScreen extends StatelessWidget {
  static const String route = '/strava_connected';
  const StravaConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    StravaState stravaState = context.read<StravaState>();
    return Scaffold(
      backgroundColor: StravaConnectedColors.background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.1,
            colors: [context.colors.accent.withValues(alpha: 0.32), StravaConnectedColors.background],
            stops: const [0, 0.64],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                CheckMarkWidget(),
                const SizedBox(height: 24),
                Text(
                  "Strava's connected",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: StravaConnectedColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "That's it — nothing else to do. Go climb something.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: StravaConnectedColors.textSubtitle),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                const StravaConnectedStepTile(number: 1, text: 'You record a walk on Strava, same as always'),
                const SizedBox(height: 12),
                const StravaConnectedStepTile(number: 2, text: 'We check it against all 282 summits'),
                const SizedBox(height: 12),
                const StravaConnectedStepTile(number: 3, text: "Next time you open 282, confirm and it's on your map"),
                const Spacer(),
                CtaButton(
                  height: 56,
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.route, (route) => false);
                  },
                  child: const Text('Back to my map'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    stravaState.startHistoricalScan();
                    Navigator.of(context).pushNamed(StravaScanningScreen.route);
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Missing a few from before? ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: StravaConnectedColors.textMuted),
                      children: [
                        TextSpan(
                          text: 'Scan my Strava history',
                          style: TextStyle(color: StravaConnectedColors.accentText, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Powered by Strava',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: StravaConnectedColors.textMuted.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
