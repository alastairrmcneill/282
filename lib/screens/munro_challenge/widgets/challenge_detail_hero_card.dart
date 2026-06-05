import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/munro_challenge/screens/create_munro_challenge_screen.dart';

class ChallengeDetailHeroCard extends StatelessWidget {
  final int completed;
  final int goal;

  const ChallengeDetailHeroCard({
    super.key,
    required this.completed,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (completed / goal).clamp(0.0, 1.0) : 0.0;
    final isComplete = completed >= goal;
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border, width: 0.65),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsRegular.trophy, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateTime.now().year} Challenge',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      isComplete ? 'Goal achieved!' : 'In progress',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.colors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              if (isComplete) const Text('🎉', style: TextStyle(fontSize: 28)),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: context.colors.border,
                    valueColor: AlwaysStoppedAnimation(context.colors.accent),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$completed',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      'of $goal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.colors.textMuted,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$percent% complete',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textMuted,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(CreateMunroChallengeScreen.route),
              child: const Text('Update Challenge Goal'),
            ),
          ),
        ],
      ),
    );
  }
}
