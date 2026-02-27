import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:two_eight_two/screens/onboarding/state/onboarding_state.dart';
import 'package:two_eight_two/screens/onboarding/screens/welcome_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/progress_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/achievement_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/community_screen.dart';

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
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onGetStarted() async {
    context.read<OnboardingState>().markOnboardingCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingState>();
    return Scaffold(
      body: Stack(
        children: [
          // PageView with screens
          RepaintBoundary(
            child: PageView(
              controller: _pageController,
              onPageChanged: (value) => state.goToPage(value),
              children: [
                WelcomeScreen(onNext: _nextPage),
                ProgressScreen(onNext: _nextPage, onBack: _previousPage),
                AchievementScreen(onNext: _nextPage, onBack: _previousPage),
                CommunityScreen(onNext: _onGetStarted),
              ],
            ),
          ),
          // Page indicator dots
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
                  dotColor: state.currentPage == 1 ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
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
