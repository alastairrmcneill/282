import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class BulkMunroUpdateDialog extends StatelessWidget {
  const BulkMunroUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhosphorIconsRegular.mountains,
                size: 36,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bagged a few already?',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "If you've climbed Munros before joining, log all your past summits in one go — no need to add them one by one.",
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () {
                final bulkMunroUpdateState = context.read<BulkMunroUpdateState>();
                final munroCompletionState = context.read<MunroCompletionState>();
                final munroState = context.read<MunroState>();
                bulkMunroUpdateState.setStartingBulkMunroUpdateList = munroCompletionState.munroCompletions;
                munroState.setBulkMunroUpdateFilterString = '';
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes, log past summits'),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, just this one'),
            ),
          ],
        ),
      ),
    );
  }
}
