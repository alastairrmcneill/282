import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/app_cached_image.dart';

class MunroCompletedTile extends StatelessWidget {
  final Munro munro;
  final MunroCompletion? completion;

  const MunroCompletedTile({
    super.key,
    required this.munro,
    required this.completion,
  });

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    final height = settingsState.metricHeight ? '${munro.meters}m' : '${munro.feet}ft';
    final formattedDate =
        completion?.dateTimeCompleted != null ? DateFormat('d MMM yyyy').format(completion!.dateTimeCompleted) : null;
    final rating = munro.averageRating?.toStringAsFixed(1) ?? '0';

    final dot = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        '•',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.textMuted),
      ),
    );

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        MunroScreen.route,
        arguments: MunroScreenArgs(munro: munro),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: context.colors.border, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 90,
                child: AppCachedImage(imageUrl: munro.pictureURL),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        munro.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            height,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.textMuted),
                          ),
                          dot,
                          Text(
                            munro.area,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.textMuted),
                          ),
                          dot,
                          Text(
                            rating,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.textMuted),
                          ),
                          const SizedBox(width: 3),
                          const Icon(CupertinoIcons.star_fill, size: 10, color: Colors.amber),
                        ],
                      ),
                      if (formattedDate != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Completed $formattedDate',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
