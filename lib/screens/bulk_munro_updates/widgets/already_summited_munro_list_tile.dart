import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AlreadySummitedMunroListTile extends StatelessWidget {
  final Munro munro;
  final DateTime summitedDate;
  const AlreadySummitedMunroListTile({super.key, required this.munro, required this.summitedDate});

  @override
  Widget build(BuildContext context) {
    SettingsState settingsState = context.read<SettingsState>();

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: MyColors.accentColor,
          width: 0.2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      color: MyColors.accentColor.withValues(alpha: 0.05),
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
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.lockSimple,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Completed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
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
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.mutedText),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('•',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.mutedText)),
                      ),
                      Text(
                        munro.area,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: MyColors.mutedText),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                    thickness: 0.5,
                    color: Colors.grey[300],
                  ),
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.calendarBlank,
                        size: 16,
                        color: MyColors.mutedText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(summitedDate),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: MyColors.mutedText,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15, top: 15),
            child: CustomCheckbox(
              value: true,
              onChanged: (value) {},
              targetSize: 18,
              activeFillColor: MyColors.accentColor.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}
