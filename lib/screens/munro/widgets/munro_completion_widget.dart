import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroCompletionWidget extends StatelessWidget {
  final int index;
  final MunroCompletion munroCompletion;
  final Munro munro;
  const MunroCompletionWidget({super.key, required this.index, required this.munroCompletion, required this.munro});

  @override
  Widget build(BuildContext context) {
    final munroCompletionState = context.read<MunroCompletionState>();
    List<ActionMenuItems> items = [
      ActionMenuItems(
        title: 'Remove',
        isDestructive: true,
        onPressed: () {
          munroCompletionState.removeMunroCompletion(
            munroCompletion: munroCompletion,
          );
        },
      ),
    ];

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Card(
        margin: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: SizedBox(width: 100, height: 100, child: CachedMunroImage(imageUrl: munro.pictureURL)),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      munro.name,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.titleMedium!,
                    ),
                    munro.extra == null || munro.extra == ""
                        ? const SizedBox()
                        : Text(
                            "(${munro.extra})",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                    const SizedBox(height: 10),
                    Text(
                      'Summit #${index + 1} - ${DateFormat("dd/MM/yyyy").format(munroCompletion.dateTimeCompleted)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                PhosphorIconsBold.dotsThreeVertical,
                color: context.colors.textMuted,
              ),
              onPressed: () => showActionSheet(context, items),
            )
          ],
        ),
      ),
    );
  }
}
