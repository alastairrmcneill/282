import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class BulkMunroUpdateDialog extends StatelessWidget {
  const BulkMunroUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Already bagged some Munros?',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Get started faster by logging your past climbs in one go. It only takes a minute and you\'ll be up to date straight away.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final bulkMunroUpdateState = context.read<BulkMunroUpdateState>();
                final munroCompletionState = context.read<MunroCompletionState>();
                final munroState = context.read<MunroState>();

                bulkMunroUpdateState.setStartingBulkMunroUpdateList =
                    munroCompletionState.munroCompletions;
                munroState.setBulkMunroUpdateFilterString = '';

                Navigator.of(context).pushNamed(BulkMunroUpdateScreen.route);
              },
              child: const Text("Let's Go"),
            ),
            const SizedBox(height: 8),
            SecondaryButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }
}
