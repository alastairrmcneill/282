import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class ProfileChallengeCard extends StatelessWidget {
  const ProfileChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileState>();
    final achievementsState = context.watch<AchievementsState>();

    final target = profileState.profile?.annualGoalTarget ?? 0;
    final progress = profileState.profile?.annualGoalProgress ?? 0;
    final year = profileState.profile?.annualGoalYear ?? DateTime.now().year;
    final annualGoalId = profileState.profile?.annualGoalId ?? '';
    final isCurrentUser = profileState.isCurrentUser;

    if (target == 0) return const SizedBox.shrink();

    final percent = (progress / target).clamp(0.0, 1.0);
    final remaining = target - progress;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isCurrentUser
            ? () {
                final match = achievementsState.achievements.where((a) => a.achievementId == annualGoalId);
                if (match.isNotEmpty) {
                  achievementsState.reset();
                  achievementsState.setCurrentAchievement = match.first;
                  Navigator.of(context).pushNamed(MunroChallengeDetailScreen.route);
                }
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ChallengeIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$year Challenge',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500, color: context.colors.textPrimary),
                        ),
                        Text(
                          'Your annual goal',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (isCurrentUser)
                    Icon(Icons.chevron_right, color: context.colors.textMuted, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$progress',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: context.colors.textPrimary,
                          ),
                    ),
                    TextSpan(
                      text: ' / $target munros',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: context.colors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 8,
                  backgroundColor: context.colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                remaining > 0 ? '$remaining more to reach your goal' : 'Goal reached!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blue.shade400.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(PhosphorIconsRegular.target, color: Colors.blue.shade400, size: 20),
    );
  }
}
