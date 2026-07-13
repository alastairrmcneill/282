import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class ProfileLogPastCard extends StatelessWidget {
  const ProfileLogPastCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final bulkState = context.read<BulkMunroUpdateState>();
          final munroCompletionState = context.read<MunroCompletionState>();
          final munroState = context.read<MunroState>();
          bulkState.setStartingBulkMunroUpdateList = munroCompletionState.munroCompletions;
          munroState.clearFilterAndSorting();
          Navigator.of(context).pushNamed(BulkMunroUpdateScreen.route);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _NavCardIcon(icon: PhosphorIconsRegular.calendar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Log Past Munros', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500, color: context.colors.textPrimary)),
                    Text('Add completions without posts', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.colors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavCardIcon extends StatelessWidget {
  final IconData icon;
  const _NavCardIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.colors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: context.colors.accent, size: 20),
    );
  }
}
