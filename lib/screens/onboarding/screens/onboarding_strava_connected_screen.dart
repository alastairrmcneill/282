import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/strava/strava_connected_colors.dart';
import 'package:two_eight_two/screens/strava/widgets/widgets.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class OnboardingStravaConnectedScreen extends StatelessWidget {
  static const String route = '/onboarding/strava_connected';
  const OnboardingStravaConnectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    StravaState stravaState = context.read<StravaState>();
    return Scaffold(
      backgroundColor: StravaConnectedColors.background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.9),
            radius: 2,
            colors: [context.colors.accent.withValues(alpha: 0.4), StravaConnectedColors.background],
            stops: const [0, 0.5],
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
                  "Strava is connected!",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: StravaConnectedColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "All your activities are ready to scan",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: StravaConnectedColors.textSubtitle),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                const StravaConnectedTimelineStep(
                  number: 1,
                  eyebrow: 'Today',
                  title: "Scan every activity you have logged",
                  description:
                      'We match your history against all 282 summits and hand you the list to confirm. About 30 seconds.',
                  isActive: true,
                ),
                const StravaConnectedTimelineStep(
                  number: 2,
                  eyebrow: 'Every walk after this',
                  title: 'They log themselves',
                  description:
                      'Record on Strava as usual — new Munros turn up in 282 waiting to be confirmed. Already switched on.',
                  showConnector: false,
                ),
                const Spacer(),
                CtaButton(
                  height: 56,
                  onPressed: () {
                    stravaState.startHistoricalScan();
                    Navigator.of(context).pushNamed(StravaScanningScreen.route);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIconsBold.scan, color: StravaConnectedColors.background),
                      const SizedBox(width: 8),
                      const Text('Scan my activities', style: TextStyle(color: StravaConnectedColors.background)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    await context.read<OnboardingState>().markOnboardingCompleted(branch: 'no');
                  },
                  child: Text(
                    'Scan later',
                    style: TextStyle(color: StravaConnectedColors.textMuted.withValues(alpha: 0.6)),
                  ),
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
