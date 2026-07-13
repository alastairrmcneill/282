import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';

class MunrosCompletedScreenArgs {
  final List<MunroCompletion> munroCompletions;
  final bool isCurrentUser;

  MunrosCompletedScreenArgs({required this.munroCompletions, required this.isCurrentUser});
}

class MunrosCompletedScreen extends StatelessWidget {
  final List<MunroCompletion> munroCompletions;
  final bool isCurrentUser;

  static const String route = '/profile/munros_completed';
  const MunrosCompletedScreen({
    super.key,
    required this.munroCompletions,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final munroCompletionState = context.watch<MunroCompletionState>();

    final completedIds =
        isCurrentUser ? munroCompletionState.completedMunroIds : munroCompletions.map((mc) => mc.munroId).toSet();

    final completedMunros = munroState.munroList.where((m) => completedIds.contains(m.id)).toList();

    final totalCount = munroState.munroList.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Completed Munros'),
            Text(
              '${completedMunros.length} of $totalCount munros',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
            ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.caretLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: completedMunros.isEmpty
          ? Center(
              child: Text(
                'No Munros completed yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: completedMunros.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final munro = completedMunros[index];
                final completion = munroCompletions.firstWhere((mc) => mc.munroId == munro.id);
                return MunroCompletedTile(
                  munro: munro,
                  completion: completion,
                );
              },
            ),
    );
  }
}
