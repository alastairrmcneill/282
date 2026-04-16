import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics_base.dart';
import 'package:two_eight_two/screens/in_app_onboarding/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class InAppOnboardingScreenArgs {
  final String userId;

  InAppOnboardingScreenArgs({required this.userId});
}

class InAppOnboardingScreen extends StatefulWidget {
  final InAppOnboardingScreenArgs args;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static const String route = '/in_app_onboarding';

  InAppOnboardingScreen({super.key, required this.args});

  @override
  State<InAppOnboardingScreen> createState() => _InAppOnboardingState();
}

class _InAppOnboardingState extends State<InAppOnboardingScreen> {
  final PageController _pageController = PageController();
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InAppOnboardingState>().init(widget.args.userId);
    });
  }

  void _onPageChanged(int newPage) {
    final state = context.read<InAppOnboardingState>();
    state.setCurrentPage = newPage;

    // Log screen view on every page change
    state.analytics.track(
      AnalyticsEvent.onboardingScreenViewed,
      props: {
        AnalyticsProp.screenIndex: newPage,
      },
    );
  }

  Widget _buildPrimaryButton(InAppOnboardingState inAppOnboardingState) {
    switch (inAppOnboardingState.currentPage) {
      case 0:
        {
          return ElevatedButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Row(
              children: [
                Text('Get Started'),
              ],
            ),
          );
        }
      case 1:
        {
          return ElevatedButton(
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Row(
              children: [
                Text('Next'),
                Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          );
        }
      case 2:
        {
          return ElevatedButton(
            onPressed: () async {
              if (!widget.formKey.currentState!.validate()) {
                return;
              }
              widget.formKey.currentState!.save();

              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Row(
              children: [
                Text('Next'),
                Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          );
        }
      case 3:
        {
          return ElevatedButton(
            onPressed: () async {
              final success = await inAppOnboardingState.handleEnableNotifications();

              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(inAppOnboardingState.error.message),
                  ),
                );
              }

              await inAppOnboardingState.completeOnboarding();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomeScreen.route,
                  (Route<dynamic> route) => false,
                );
              }
            },
            child: const Text('Enable Notifications'),
          );
        }
      default:
        {
          return const SizedBox();
        }
    }
  }

  Widget _buildSecondaryButton(InAppOnboardingState inAppOnboardingState) {
    switch (inAppOnboardingState.currentPage) {
      case 3:
        {
          return TextButton(
            onPressed: () async {
              await inAppOnboardingState.handleDenyNotifications();
              await inAppOnboardingState.completeOnboarding();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomeScreen.route,
                  (Route<dynamic> route) => false,
                );
              }
            },
            child: const Text('Skip'),
          );
        }
      default:
        {
          return const SizedBox();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inAppOnboardingState = context.watch<InAppOnboardingState>();

    // Gate UI while loading
    if (inAppOnboardingState.status == InAppOnboardingStatus.loading ||
        inAppOnboardingState.status == InAppOnboardingStatus.initial) {
      return const LoadingWidget();
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/login_background1.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  PageProgressIndicator(
                    currentPageIndex: inAppOnboardingState.currentPage,
                    totalPages: 4,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        InAppOnboardingWelcome(),
                        InAppOnboardingMunroUpdates(),
                        InAppOnboardingMunroChallenge(
                          args: InAppOnboardingMunroChallengeArgs(formKey: widget.formKey),
                        ),
                        InAppOnboardingNotifications(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSecondaryButton(inAppOnboardingState),
                        _buildPrimaryButton(inAppOnboardingState),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (inAppOnboardingState.status == InAppOnboardingStatus.completing) BlockingLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}
