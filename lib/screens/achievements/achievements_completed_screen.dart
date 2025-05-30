import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/achievements/state/achievements_state.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AchievementsCompletedScreen extends StatefulWidget {
  const AchievementsCompletedScreen({super.key});

  static const String route = "/achievements_completed";

  @override
  State<AchievementsCompletedScreen> createState() => _AchievementsCompletedScreenState();
}

class _AchievementsCompletedScreenState extends State<AchievementsCompletedScreen> {
  late ConfettiController confettiController;
  @override
  void initState() {
    confettiController = ConfettiController(duration: const Duration(seconds: 1));
    super.initState();
  }

  @override
  dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
    confettiController.play();

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          achievementsState.setRecentlyCompletedAchievements = [];

          Navigator.pushNamedAndRemoveUntil(
            context,
            HomeScreen.route, // The name of the route you want to navigate to
            (Route<dynamic> route) => false, // This predicate ensures all routes are removed
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                gravity: 0.05,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            const Text('🎉', style: TextStyle(fontSize: 60)),
                            Text(
                              'Congratulations!',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'You have completed the following achievements',
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                    fontWeight: FontWeight.w300,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const PaddedDivider(),
                            ...achievementsState.recentlyCompletedAchievements.map(
                              (e) => Column(
                                children: [
                                  Text(e.name, style: Theme.of(context).textTheme.headlineMedium),
                                  Text(e.description, style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        height: 44,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            AchievementsState achievementsState =
                                Provider.of<AchievementsState>(context, listen: false);
                            achievementsState.setRecentlyCompletedAchievements = [];

                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              HomeScreen.route, // The name of the route you want to navigate to
                              (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                            );
                          },
                          child: const Text('Woohoo!'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
