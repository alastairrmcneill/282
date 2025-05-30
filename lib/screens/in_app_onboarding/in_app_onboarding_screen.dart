import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/in_app_onboarding/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class InAppOnboarding extends StatefulWidget {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  static const String route = '/in_app_onboarding';

  InAppOnboarding({super.key});

  @override
  State<InAppOnboarding> createState() => _InAppOnboardingState();
}

class _InAppOnboardingState extends State<InAppOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Log first screen view
    AnalyticsService.logOnboardingScreenViewed(screenIndex: _currentPage);
    AnalyticsService.logOnboardingStarted();
  }

  void _onPageChanged(int newPage) {
    setState(() {
      _currentPage = newPage;
    });

    // Log screen view on every page change
    AnalyticsService.logOnboardingScreenViewed(screenIndex: newPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  currentPageIndex: _currentPage,
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
                      InAppOnboardingFindFriends(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentPage == 0
                          ? const SizedBox()
                          : TextButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: const Text('Back'),
                            ),
                      _currentPage == 3
                          ? ElevatedButton(
                              onPressed: () async {
                                AchievementService.setMunroChallenge(context);
                                MunroService.bulkUpdateMunros(context);
                                SharedPreferencesService.setShowBulkMunroDialog(false);
                                AnalyticsService.logOnboardingCompleted();
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  HomeScreen.route,
                                  (Route<dynamic> route) => false,
                                );
                              },
                              child: const Text('Get Started'),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (_currentPage == 2) {
                                  if (!widget.formKey.currentState!.validate()) {
                                    return;
                                  }
                                  widget.formKey.currentState!.save();
                                }

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
                            ),
                    ],
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
