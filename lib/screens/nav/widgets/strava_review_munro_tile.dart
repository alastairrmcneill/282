import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaReviewMunroTile extends StatelessWidget {
  final MunroMatch munroMatch;
  const StravaReviewMunroTile({super.key, required this.munroMatch});

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    final settingsState = context.read<SettingsState>();
    final stravaActivityReviewState = context.read<StravaActivityReviewState>();
    final selected = stravaActivityReviewState.selectedMatchIds.contains(munroMatch.id);

    final munro = munroState.munroList.firstWhere((munro) => munro.id == munroMatch.munroId);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => stravaActivityReviewState.toggleMatchSelection(munroMatch.id),
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: selected ? context.colors.accent : context.colors.border,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          color: selected ? context.colors.accent.withValues(alpha: 0.05) : Theme.of(context).cardColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        munro.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            settingsState.metricHeight
                                ? "${munro.meters.thousandsSeparator()}m"
                                : "${munro.feet.thousandsSeparator()}ft",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.textMuted),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('•',
                                style:
                                    Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.textMuted)),
                          ),
                          Text(
                            munro.area,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: context.colors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              CustomCheckbox(
                value: selected,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
