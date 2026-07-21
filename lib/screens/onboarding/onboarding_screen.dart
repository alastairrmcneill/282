import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/screens/onboarding/state/onboarding_state.dart';
import 'package:two_eight_two/screens/onboarding/screens/welcome_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/progress_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/achievement_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/munro_question_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/onboarding_bulk_log_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String route = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingState>().init();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final state = context.read<OnboardingState>();
    if (!state.isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    final state = context.read<OnboardingState>();
    context.read<Analytics>().track(
      AnalyticsEvent.onboardingBackTapped,
      props: {
        AnalyticsProp.stepNumber: state.currentPage + 1,
        AnalyticsProp.stepName: state.currentStepName,
        AnalyticsProp.source: 'first_run_onboarding',
      },
    );
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onNo() async {
    await context.read<OnboardingState>().markOnboardingCompleted(branch: 'no');
    // RootGate rebuilds automatically when hasCompletedOnboarding changes
  }

  Future<void> _onYes() async {
    if (mounted) {
      Navigator.pushNamed(context, OnboardingBulkLogScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingState>();

    // Pages 1 and 3 have light backgrounds — use dark dots for contrast
    final bool lightBackground = state.currentPage == 1 || state.currentPage == 3;

    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            child: PageView(
              controller: _pageController,
              onPageChanged: (value) => state.goToPage(value),
              children: [
                WelcomeScreen(onNext: _nextPage),
                ProgressScreen(onNext: _nextPage, onBack: _previousPage),
                AchievementScreen(onNext: _nextPage, onBack: _previousPage),
                MunroQuestionScreen(onNo: _onNo, onYes: _onYes, source: 'first_run_onboarding'),
              ],
            ),
          ),
          // Hide dots on question page — it has its own CTA layout
          if (state.currentPage < 3)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: OnboardingState.totalPages,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: const Color(0xFF10b981),
                    dotColor: lightBackground
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.3),
                    spacing: 8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
