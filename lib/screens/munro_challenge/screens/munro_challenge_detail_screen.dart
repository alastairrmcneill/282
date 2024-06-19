import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro_challenge/screens/create_munro_challenge_screen.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroChallengeDetailScreen extends StatelessWidget {
  const MunroChallengeDetailScreen({super.key});

  Widget _buildMessage(BuildContext context, Achievement achievement) {
    if (achievement.completed) {
      return Column(
        children: [
          const SizedBox(height: 20),
          const Text('🎉', style: TextStyle(fontSize: 60)),
          Text(
            'Congratulations!',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 20),
          Text(
            'You have achieved your goal for the year!.',
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.w300,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      if (achievement.criteria[CriteriaFields.count] == 0) {
        return Column(
          children: [
            const SizedBox(height: 20),
            const Text('🏔️', style: TextStyle(fontSize: 60)),
            Text(
              'You haven\'t set a goal for the year yet.',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      } else {
        return Column(
          children: [
            const SizedBox(height: 20),
            const Text('🏔️', style: TextStyle(fontSize: 60)),
            Text(
              'You still have a few to go before you reach your goal for the year.',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context);

    Achievement achievement = achievementsState.currentAchievement!;
    return Scaffold(
      appBar: AppBar(
        title: Text(achievement.name),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessage(context, achievement),
            const PaddedDivider(),
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            achievement.type == AchievementTypes.multiMunroDay
                ? const SizedBox()
                : Text("Progress: ${achievement.progress}/${achievement.criteria["count"]}"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateMunroChallengeScreen(),
                    ),
                  );
                },
                child: const Text('Update Challenge'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
