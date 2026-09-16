import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/onboarding/state/onboarding_state.dart';
import 'package:two_eight_two/screens/onboarding/screens/munro_question_screen.dart';
import 'package:two_eight_two/screens/onboarding/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';

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
        AnalyticsProp.source: AnalyticsSource.firstRunOnboarding,
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
                OnboardingWelcomeScreen(onNext: _nextPage),
                MunroQuestionScreen(onNo: _onNo, onYes: _onYes, source: AnalyticsSource.firstRunOnboarding),
              ],
            ),
          ),
          // Hide dots on question page — it has its own CTA layout
          if (state.currentPage > 1)
            Positioned(
              top: 32,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      OnboardingBackButton(
                        onPressed: _previousPage,
                        backButtonLight: true,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (state.currentPage) / OnboardingState.totalPages,
                          borderRadius: BorderRadius.circular(100),
                          color: context.colors.accent,
                          backgroundColor: context.colors.divider.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
