import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:two_eight_two/screens/nav/state/app_bootstrap_state.dart';
import 'package:two_eight_two/screens/onboarding/state/onboarding_state.dart';
import 'package:two_eight_two/screens/onboarding/widgets/onboarding_buttons.dart';
import 'package:two_eight_two/screens/onboarding/screens/welcome_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/progress_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/achievement_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/community_screen.dart';
import 'package:two_eight_two/screens/onboarding/screens/final_screen.dart';
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    context.read<OnboardingState>().goToPage(page);
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
    // Mark onboarding as completed
    await context.read<AppBootstrapState>().markOnboardingCompleted();

    // Navigate to home screen
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      HomeScreen.route,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with screens
          RepaintBoundary(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                WelcomeScreen(),
                ProgressScreen(),
                AchievementScreen(),
                CommunityScreen(),
                FinalScreen(onGetStarted: _onGetStarted),
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
                  dotColor: Colors.white.withOpacity(0.3),
                  spacing: 8,
                ),
              ),
            ),
          ),
          // Navigation buttons
          Positioned(
            bottom: 96,
            left: 0,
            right: 0,
            child: Consumer<OnboardingState>(
              builder: (context, state, child) {
                if (state.isLastPage) {
                  // Show special CTA button on last page
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OnboardingPrimaryButton(
                            onPressed: _onGetStarted,
                            text: 'Start Bagging Munros',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _previousPage,
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Color(0xFFe2e8f0),
                          ),
                          label: const Text(
                            'Go Back',
                            style: TextStyle(
                              color: Color(0xFFe2e8f0),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return OnboardingNavigationButtons(
                    onNext: _nextPage,
                    onBack: state.isFirstPage ? null : _previousPage,
                    nextText: 'Continue',
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
