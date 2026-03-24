import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroSummitedWidget extends StatelessWidget {
  final Munro munro;
  const MunroSummitedWidget({super.key, required this.munro});

  Widget _buildBody(
    BuildContext context,
    List<MunroCompletion> completions,
  ) {
    final textTheme = Theme.of(context).textTheme;
    if (completions.length == 1) {
      DateTime date = completions.first.dateTimeCompleted;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completed',
            style: textTheme.titleMedium!.copyWith(
              color: MyColors.accentColor,
            ),
          ),
          Text(
            'You climbed this on ${DateFormat('dd/MM/yyyy').format(date)}',
            style: textTheme.bodyMedium!.copyWith(
              color: MyColors.subtitleColor.withAlpha(170),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completed ${completions.length} times',
            style: textTheme.titleMedium!.copyWith(
              color: MyColors.accentColor,
            ),
          ),
          ...completions.map((date) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '• ${DateFormat('dd/MM/yyyy').format(date.dateTimeCompleted)}',
                style: textTheme.bodyMedium!.copyWith(
                  color: MyColors.subtitleColor.withAlpha(170),
                ),
              ),
            );
          }),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final munroCompletionState = context.watch<MunroCompletionState>();

    List<MunroCompletion> completions =
        munroCompletionState.munroCompletions.where((mc) => mc.munroId == munro.id).toList();

    if (completions.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(45, 106, 79, 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color.fromRGBO(45, 106, 79, 0.2),
            width: 0.7,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              PhosphorIconsFill.checkCircle,
              color: Color.fromRGBO(45, 106, 79, 1),
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildBody(context, completions)),
          ],
        ),
      ),
    );
  }
}
