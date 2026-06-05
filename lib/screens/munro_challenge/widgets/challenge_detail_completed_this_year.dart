import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';

class CompletedThisYearSection extends StatelessWidget {
  final List<MunroCompletion> completions;
  final List<Munro> munros;
  final int completedCount;

  const CompletedThisYearSection({
    super.key,
    required this.completions,
    required this.munros,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completed This Year',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '$completedCount ${completedCount == 1 ? 'munro' : 'munros'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.textMuted,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (munros.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No munros completed this year yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colors.textMuted,
                    ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: munros.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final munro = munros[index];
              final completion = completions.firstWhere((mc) => mc.munroId == munro.id);
              return MunroCompletedTile(munro: munro, completion: completion);
            },
          ),
      ],
    );
  }
}
