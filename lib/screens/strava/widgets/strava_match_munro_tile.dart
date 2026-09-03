import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/strava/helpers/match_strava_activity.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaMatchMunroTile extends StatelessWidget {
  final StravaMunroMatch munroMatch;
  final bool isSelected;
  final bool isRepeat;
  final Function(bool?) onSelected;
  const StravaMatchMunroTile({
    super.key,
    required this.munroMatch,
    required this.isSelected,
    required this.isRepeat,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isSelected ? context.colors.accent : context.colors.border,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        color: isSelected ? context.colors.accent.withValues(alpha: 0.05) : Theme.of(context).cardColor,
        child: InkWell(
          onTap: () => onSelected(!isSelected),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        munroMatch.munro.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            DateFormat('d MMM yyyy').format(munroMatch.stravaActivity.startDate.toLocal()),
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.textMuted),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('•',
                                style:
                                    Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.textMuted)),
                          ),
                          isRepeat
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: context.colors.warningBackground,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Text(
                                      'REPEAT',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: context.colors.warning),
                                    ),
                                  ),
                                )
                              : Row(
                                  children: [
                                    Text(
                                      munroMatch.stravaActivity.activityType,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: context.colors.textMuted),
                                    ),
                                    munroMatch.stravaActivity.distanceM != null
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text('•',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(color: context.colors.textMuted)),
                                          )
                                        : const SizedBox.shrink(),
                                    munroMatch.stravaActivity.distanceM != null
                                        ? Text(
                                            '${(munroMatch.stravaActivity.distanceM! / 1000).toStringAsFixed(1)} km',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: context.colors.textMuted),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              CustomCheckbox(
                size: 22,
                value: isSelected,
                onChanged: onSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
