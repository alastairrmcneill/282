import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/achievements/state/achievements_state.dart';
import 'package:two_eight_two/screens/achievements/widgets/widgets.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AchievementsCompletedDialog extends StatefulWidget {
  final List<Achievement> recentlyCompletedAchievements;
  const AchievementsCompletedDialog({super.key, required this.recentlyCompletedAchievements});

  @override
  State<AchievementsCompletedDialog> createState() => _AchievementsCompletedDialogState();
}

class _AchievementsCompletedDialogState extends State<AchievementsCompletedDialog> {
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
    final achievementsState = context.read<AchievementsState>();
    confettiController.play();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            gravity: 0.07,
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
                          style: Theme.of(context).textTheme.headlineMedium,
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
                        ...widget.recentlyCompletedAchievements.map(
                          (e) => AchievementCompletedWidget(achievement: e),
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
                        for (var achievement in widget.recentlyCompletedAchievements) {
                          achievementsState.acknowledgeAchievement(achievement: achievement);
                        }
                        Navigator.of(context).pop();
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
    );
  }
}
