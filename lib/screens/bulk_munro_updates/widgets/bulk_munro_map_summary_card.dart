import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class BulkMunroMapSummaryCard extends StatelessWidget {
  final int munroId;
  const BulkMunroMapSummaryCard({super.key, required this.munroId});

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final munroCompletionState = context.watch<MunroCompletionState>();
    final bulkMunroUpdateState = context.watch<BulkMunroUpdateState>();
    final settingsState = context.read<SettingsState>();
    final userState = context.read<UserState>();

    final Munro munro = munroState.munroList.firstWhere(
      (m) => m.id == munroId,
      orElse: () => Munro.empty,
    );

    if (munro.id == Munro.empty.id) return const SizedBox();

    // Already-summited: locked, read-only
    final existingCompletion = munroCompletionState.munroCompletions
        .where((c) => c.munroId == munroId)
        .firstOrNull;
    final bool alreadySummited = existingCompletion != null;

    // Bulk selection — single completion per munro, matching list tile behaviour
    final List<DateTime> summitedDates = bulkMunroUpdateState.bulkMunroUpdateList
        .where((mc) => mc.munroId == munroId)
        .map((mc) => mc.dateTimeCompleted)
        .toList();
    final bool summited = summitedDates.isNotEmpty;
    final DateTime firstSummitedDate = summitedDates.isNotEmpty ? summitedDates[0] : DateTime.now();
    final bool isDefaultDate = summited &&
        firstSummitedDate.hour == 0 &&
        firstSummitedDate.minute == 0 &&
        firstSummitedDate.second == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                munro.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.w800, height: 1.1, fontSize: 16),
              ),
              if (munro.extra != null && munro.extra!.isNotEmpty)
                Text(
                  "(${munro.extra})",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 12),
                ),
              const SizedBox(height: 4),
              Text(
                "${munro.area} · ${settingsState.metricHeight ? "${munro.meters}m" : "${munro.feet}ft"}",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 12),
              ),
              const Divider(height: 20, thickness: 0.5),
              if (alreadySummited) ...[
                Row(
                  children: [
                    Icon(PhosphorIconsRegular.lockSimple, size: 14, color: Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      'Already summited',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.calendarBlank,
                            size: 14, color: context.colors.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd/MM/yyyy').format(existingCompletion.dateTimeCompleted),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                if (!summited)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: context.colors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final DateTime now = DateTime.now();
                        bulkMunroUpdateState.addMunroCompleted(MunroCompletion(
                          userId: userState.currentUser?.uid ?? "",
                          munroId: munroId,
                          dateTimeCompleted: DateTime(now.year, now.month, now.day, 0, 0, 0),
                        ));
                      },
                      child: const Text('Mark as done'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.accent,
                        side: BorderSide(color: context.colors.accent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => bulkMunroUpdateState.removeMunroCompletion(munroId),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIconsRegular.checkCircle, size: 16, color: context.colors.accent),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Added', textAlign: TextAlign.center),
                          ),
                          Icon(PhosphorIconsRegular.x, size: 16, color: context.colors.accent),
                        ],
                      ),
                    ),
                  ),
                if (summited) ...[
                  Divider(height: 20, thickness: 0.5, color: Colors.grey[300]),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: isDefaultDate ? DateTime.now() : firstSummitedDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        final DateTime date = picked.add(const Duration(hours: 12, seconds: 1));
                        bulkMunroUpdateState.updateMunroCompleted(MunroCompletion(
                          userId: userState.currentUser?.uid ?? "",
                          munroId: munroId,
                          dateTimeCompleted: date,
                        ));
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          isDefaultDate
                              ? PhosphorIconsRegular.plus
                              : PhosphorIconsRegular.calendarBlank,
                          size: 16,
                          color: context.colors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isDefaultDate
                              ? 'Add date (optional)'
                              : DateFormat('dd/MM/yyyy').format(firstSummitedDate),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: context.colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
