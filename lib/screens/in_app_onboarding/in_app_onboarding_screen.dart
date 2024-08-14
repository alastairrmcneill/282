import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/in_app_onboarding/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class InAppOnboarding extends StatefulWidget {
  const InAppOnboarding({super.key});

  @override
  State<InAppOnboarding> createState() => _InAppOnboardingState();
}

class _InAppOnboardingState extends State<InAppOnboarding> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    NavigationState navigationState = Provider.of<NavigationState>(context);
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
                  totalPages: 3, // Change this based on the total number of pages
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      InAppOnboardingWelcome(),
                      InAppOnboardingMunroUpdates(),
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
                              child: const Text('Back')),
                      _currentPage == 2
                          ? ElevatedButton(
                              onPressed: () async {
                                MunroService.bulkUpdateMunros(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                                  (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                                );
                              },
                              child: const Text('Get Started'))
                          : ElevatedButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: const Row(
                                children: [
                                  Text('Next'),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                  )
                                ],
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
