import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/munro_challenge/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreateMunroChallengeScreen extends StatefulWidget {
  static const String route = '/munro_challenge/create';
  const CreateMunroChallengeScreen({super.key});

  @override
  State<CreateMunroChallengeScreen> createState() =>
      _CreateMunroChallengeScreenState();
}

class _CreateMunroChallengeScreenState
    extends State<CreateMunroChallengeScreen> {
  int _goal = 12;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target =
          context.read<AchievementsState>().currentAchievement?.annualTarget;
      if (target != null && mounted) setState(() => _goal = target);
    });
  }

  void _save(AchievementsState achievementsState) {
    achievementsState.setAchievementFormCount = _goal;
    achievementsState.setMunroChallenge();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementsState>(
      builder: (context, achievementsState, _) {
        if (achievementsState.status == AchievementsStatus.error) {
          return Scaffold(
            appBar: AppBar(title: const Text('Update Goal')),
            body: CenterText(text: achievementsState.error.message),
          );
        }

        final completedCount = context
            .watch<MunroCompletionState>()
            .munroCompletions
            .where((mc) => mc.dateTimeCompleted.year == DateTime.now().year)
            .length;

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Update Goal'),
                    Text(
                      'Set your ${DateTime.now().year} goal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .appBarTheme
                                .foregroundColor
                                ?.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
                centerTitle: false,
              ),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: BottomButtonBar(
                  child: PrimaryButton(
                    onPressed: () => _save(achievementsState),
                    child: const Text('Save Goal'),
                  ),
                ),
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ChallengeProgressCard(
                    completedCount: completedCount,
                    goal: _goal,
                  ),
                  const SizedBox(height: 20),
                  ChallengeGoalSelector(
                    goal: _goal,
                    onChanged: (value) => setState(() => _goal = value),
                  ),
                  const SizedBox(height: 20),
                  ChallengeImpactStats(
                    goal: _goal,
                    completedCount: completedCount,
                  ),
                ],
              ),
            ),
            if (achievementsState.status == AchievementsStatus.loading)
              Container(
                color: Colors.transparent,
                child: const LoadingWidget(),
              ),
          ],
        );
      },
    );
  }
}
