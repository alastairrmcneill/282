import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/onboarding/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroQuestionScreen extends StatefulWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;
  final String source;

  const MunroQuestionScreen({super.key, required this.onYes, required this.onNo, required this.source});

  @override
  State<MunroQuestionScreen> createState() => _MunroQuestionScreenState();
}

class _MunroQuestionScreenState extends State<MunroQuestionScreen> with SingleTickerProviderStateMixin {
  int get _stepNumber => widget.source == AnalyticsSource.inAppOnboarding ? 1 : 4;

  void _handleYes() {
    context.read<Analytics>().track(
      AnalyticsEvent.munroQuestionAnswered,
      props: {
        AnalyticsProp.response: AnalyticsResponse.yes,
        AnalyticsProp.source: widget.source,
        AnalyticsProp.stepNumber: _stepNumber,
        AnalyticsProp.stepName: 'munro_question',
      },
    );
    widget.onYes();
  }

  void _handleNo() {
    context.read<Analytics>().track(
      AnalyticsEvent.munroQuestionAnswered,
      props: {
        AnalyticsProp.response: AnalyticsResponse.no,
        AnalyticsProp.source: widget.source,
        AnalyticsProp.stepNumber: _stepNumber,
        AnalyticsProp.stepName: 'munro_question',
      },
    );
    widget.onNo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          Stack(
            children: [
              // Background photo
              Image.network(
                'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0f4c35)),
                height: 400,
              ),
              // Gradient to background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        context.colors.background.withOpacity(0.1),
                        context.colors.background,
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "How many have\nyou already done?",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Log all your previous Munro summits in one go!',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.colors.textSubtitle,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: context.colors.stravaOrange,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: context.colors.stravaBackground,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/strava_solid.svg',
                                    width: 12,
                                    height: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'FASTEST',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: context.colors.stravaOrange),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Find them from Strava',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We read your activity history, work out which summits you crossed, and show you the list to confirm.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
                          ),
                          const SizedBox(height: 16),
                          CtaButton(
                            height: 52,
                            backgroundColor: context.colors.stravaOrange,
                            onPressed: () async {
                              await OnboardingSignInBottomSheet.show(context);
                              // final connectionStatus = await context
                              //     .read<OnboardingState>()
                              //     .connectWithStrava();

                              // if (connectionStatus ==
                              //     StravaConnectionStatus.connected) {
                              //   if (context.mounted) {
                              //     Navigator.of(context).pushReplacementNamed(
                              //         OnboardingStravaConnectedScreen.route);
                              //   }
                              // } else {}
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/strava_solid_white.svg',
                                  width: 20,
                                  height: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Connect with Strava',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pick them on a map',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your summits manually on the map or list.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
                        ),
                        const SizedBox(height: 16),
                        CtaButton(
                          height: 52,
                          backgroundColor: context.colors.background,
                          borderColor: context.colors.middleGrey.withOpacity(0.5),
                          onPressed: () {},
                          child: Text(
                            'Choose manually',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: context.colors.textSubtitle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () async {
                      await context.read<OnboardingState>().markOnboardingCompleted(branch: 'no');
                    },
                    child: Text(
                      "I'm starting from zero",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.light.textMuted,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
