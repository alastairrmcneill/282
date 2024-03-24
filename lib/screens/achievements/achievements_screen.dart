import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/achievements/state/achievements_state.dart';
import 'package:two_eight_two/screens/screens.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const String route = "/achievements_screen";

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);

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
        appBar: AppBar(
          title: const Text('Achievements'),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {
                AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
                achievementsState.setRecentlyCompletedAchievements = [];

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomeScreen.route, // The name of the route you want to navigate to
                  (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                );
              },
              icon: Icon(Icons.close),
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              ...achievementsState.recentlyCompletedAchievements.map((e) => Text(e.name)),
            ],
          ),
        ),
      ),
    );
  }
}
