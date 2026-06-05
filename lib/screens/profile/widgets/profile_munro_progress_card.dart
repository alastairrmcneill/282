import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class ProfileMunroProgressCard extends StatelessWidget {
  const ProfileMunroProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileState>();
    final completed = profileState.profile?.munrosCompleted ?? 0;
    const total = 282;
    final percent = completed / total;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await profileState.getProfileMunroCompletions();
          if (context.mounted) {
            Navigator.of(context).pushNamed(
              MunrosCompletedScreen.route,
              arguments: MunrosCompletedScreenArgs(
                munroCompletions: profileState.munroCompletions,
                isCurrentUser: profileState.isCurrentUser,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CardIcon(icon: PhosphorIconsRegular.mountains),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Munros Completed',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.colors.textMuted),
                        ),
                        Text(
                          'Progress towards all 282',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: context.colors.textMuted, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$completed',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: context.colors.textPrimary,
                          ),
                    ),
                    TextSpan(
                      text: ' / $total',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.colors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _ProgressBar(value: percent, color: context.colors.accent),
              const SizedBox(height: 6),
              Text(
                '${(percent * 100).round()}% complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;

  const _CardIcon({required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colors.accent;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: accent, size: 20),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        backgroundColor: context.colors.border,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
