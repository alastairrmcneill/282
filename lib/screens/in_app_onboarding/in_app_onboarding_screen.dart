import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/in_app_onboarding/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() async {
    final userId = context.read<AuthState>().currentUserId;
    final userState = context.read<UserState>();
    final munroCompletionState = context.read<MunroCompletionState>();
    final bulkMunroCompletionState = context.read<BulkMunroUpdateState>();
    await userState.readUser(uid: userId);
    await munroCompletionState.loadUserMunroCompletions();
    bulkMunroCompletionState.setStartingBulkMunroUpdateList = munroCompletionState.munroCompletions;

    context.read<MunroState>().setFilterString = "";

    final achievementsState = context.read<AchievementsState>();

    Achievement? munroChallenge = await context.read<UserAchievementsRepository>().getLatestMunroChallengeAchievement(
          userId: userState.currentUser!.uid ?? "",
        );

    achievementsState.reset();
    achievementsState.setCurrentAchievement = munroChallenge;
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
    MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context, listen: false);
    BulkMunroUpdateState bulkMunroUpdateState = Provider.of<BulkMunroUpdateState>(context, listen: false);
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
                  totalPages: 3,
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
                      )
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
                      _currentPage == 2
                          ? ElevatedButton(
                              onPressed: () async {
                                if (!widget.formKey.currentState!.validate()) {
                                  return;
                                }
                                widget.formKey.currentState!.save();
                                context.read<AchievementsState>().setMunroChallenge();
                                munroCompletionState.addBulkCompletions(
                                    munroCompletions: bulkMunroUpdateState.bulkMunroUpdateList);
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
