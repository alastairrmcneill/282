import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class GroupFilterActiveChip extends StatelessWidget {
  const GroupFilterActiveChip({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFilterState>();
    if (state.selectedFriendsUids.isEmpty) return const SizedBox.shrink();

    final count = state.selectedFriendsUids.length;
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(100),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: () => homeScreenKey.currentState?.switchTab(2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconsRegular.usersThree,
                size: 16,
                color: context.colors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                '$count ${count == 1 ? 'friend' : 'friends'} active',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
