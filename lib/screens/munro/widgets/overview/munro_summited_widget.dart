import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroSummitedWidget extends StatelessWidget {
  final Munro munro;
  const MunroSummitedWidget({super.key, required this.munro});

  Widget _buildBody(
    BuildContext context,
    List<MunroCompletion> completions,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final sorted = [...completions]..sort((a, b) => b.dateTimeCompleted.compareTo(a.dateTimeCompleted));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completed ${sorted.length} ${sorted.length == 1 ? 'time' : 'times'}',
          style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Most recent: ${DateFormat('dd/MM/yyyy').format(sorted.first.dateTimeCompleted)}',
          style: textTheme.bodySmall!.copyWith(
            color: context.colors.textSubtitle,
          ),
        ),
        const SizedBox(height: 12),
        ...sorted.map((completion) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.colors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(completion.dateTimeCompleted),
                  style: textTheme.bodySmall!.copyWith(
                    color: context.colors.textSubtitle,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final munroCompletionState = context.watch<MunroCompletionState>();

    List<MunroCompletion> completions =
        munroCompletionState.munroCompletions.where((mc) => mc.munroId == munro.id).toList();

    if (completions.isEmpty) {
      return SizedBox.shrink();
    }

    return GlassCard(
      solidLightBackground: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIconsFill.checkCircle,
            color: context.colors.accent,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildBody(context, completions)),
        ],
      ),
    );
  }
}
