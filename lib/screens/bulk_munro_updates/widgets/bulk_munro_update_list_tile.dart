import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/bulk_munro_updates/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class BulkMunroUpdateListTile extends StatelessWidget {
  final Munro munro;
  const BulkMunroUpdateListTile({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final munroCompletionState = context.watch<MunroCompletionState>();
    final bulkMunroUpdateState = context.watch<BulkMunroUpdateState>();
    final settingsState = context.read<SettingsState>();
    final userState = context.read<UserState>();

    List<DateTime> alreadySummitedDates = munroCompletionState.munroCompletions
        .where((mc) => mc.munroId == munro.id)
        .map((mc) => mc.dateTimeCompleted)
        .toList();

    var alreadySummited = alreadySummitedDates.isNotEmpty;

    if (alreadySummited) {
      return AlreadySummitedMunroListTile(munro: munro, summitedDate: alreadySummitedDates[0]);
    }

    List<DateTime> summitedDates = bulkMunroUpdateState.bulkMunroUpdateList
        .where((mc) => mc.munroId == munro.id)
        .map((mc) => mc.dateTimeCompleted)
        .toList();

    var summited = summitedDates.isNotEmpty;
    var firstSummitedDate = summitedDates.isNotEmpty ? summitedDates[0] : DateTime.now();

    // Check if the date is still the default (time is 00:00:00 means user hasn't explicitly selected a date yet)
    bool isDefaultDate =
        summited && firstSummitedDate.hour == 0 && firstSummitedDate.minute == 0 && firstSummitedDate.second == 0;

    return InkWell(
      onTap: () {
        if (summited) {
          bulkMunroUpdateState.removeMunroCompletion(munro.id);
        } else {
          DateTime now = DateTime.now();
          DateTime defaultDate = DateTime(now.year, now.month, now.day, 0, 0, 0); // 00:00:00 marks as default
          MunroCompletion mc = MunroCompletion(
            userId: userState.currentUser?.uid ?? "",
            munroId: munro.id,
            dateTimeCompleted: defaultDate,
          );

          bulkMunroUpdateState.addMunroCompleted(mc);
        }
      },
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: summited ? MyColors.accentColor : Colors.grey[300]!,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        color: summited ? MyColors.accentColor.withValues(alpha: 0.05) : Theme.of(context).cardColor,
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
                    if (summited)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            height: 20,
                            thickness: 0.5,
                            color: Colors.grey[300],
                          ),
                          InkWell(
                            onTap: () async {
                              DateTime? pickedStartDate = await showDatePicker(
                                context: context,
                                initialDate: isDefaultDate ? DateTime.now() : firstSummitedDate,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );

                              if (pickedStartDate != null) {
                                DateTime date = pickedStartDate.add(const Duration(hours: 12, seconds: 1));
                                MunroCompletion mc = MunroCompletion(
                                  userId: userState.currentUser?.uid ?? "",
                                  munroId: munro.id,
                                  dateTimeCompleted: date,
                                );

                                bulkMunroUpdateState.updateMunroCompleted(mc);
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  isDefaultDate ? PhosphorIconsRegular.plus : PhosphorIconsRegular.calendarBlank,
                                  size: 16,
                                  color: MyColors.mutedText,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isDefaultDate
                                      ? 'Add date (optional)'
                                      : DateFormat('dd/MM/yyyy').format(firstSummitedDate),
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: MyColors.mutedText,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // ...existing code...
            CustomCheckbox(
              value: summited,
              onChanged: (value) {
                if (summited) {
                  bulkMunroUpdateState.removeMunroCompletion(munro.id);
                } else {
                  DateTime now = DateTime.now();
                  DateTime defaultDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
                  MunroCompletion mc = MunroCompletion(
                    userId: userState.currentUser?.uid ?? "",
                    munroId: munro.id,
                    dateTimeCompleted: defaultDate,
                  );

                  bulkMunroUpdateState.addMunroCompleted(mc);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
