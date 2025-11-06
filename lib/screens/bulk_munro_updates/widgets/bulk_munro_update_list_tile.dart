import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/bulk_munro_updates/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class BulkMunroUpdateListTile extends StatelessWidget {
  final Munro munro;
  const BulkMunroUpdateListTile({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context);
    BulkMunroUpdateState bulkMunroUpdateState = Provider.of<BulkMunroUpdateState>(context);
    UserState userState = Provider.of<UserState>(context, listen: false);

    List<DateTime> alreadySummitedDates = munroCompletionState.munroCompletions
        .where((mc) => mc.munroId == munro.id)
        .map((mc) => mc.dateTimeCompleted)
        .toList();

    var alreadySummited = alreadySummitedDates.isNotEmpty;

    if (alreadySummited) {
      print("Already summited munro: ${munro.name} on ${alreadySummitedDates[0]}");
      return AlreadySummitedMunroListTile(munro: munro, summitedDate: alreadySummitedDates[0]);
    }

    List<DateTime> summitedDates = bulkMunroUpdateState.bulkMunroUpdateList
        .where((mc) => mc.munroId == munro.id)
        .map((mc) => mc.dateTimeCompleted)
        .toList();

    var summited = summitedDates.isNotEmpty;

    var firstSummitedDate = summitedDates.isNotEmpty ? summitedDates[0] : DateTime.now();

    TextEditingController dateController =
        TextEditingController(text: DateFormat('dd/MM/yy').format(firstSummitedDate));

    DateTime? pickedStartDate;

    return ListTile(
      title: Text(munro.name),
      subtitle: Text("${munro.extra == null || munro.extra!.isEmpty ? "" : "${munro.extra} · "}${munro.area}"),
      leading: summited ? const Icon(Icons.check) : const SizedBox(),
      trailing: summited
          ? SizedBox(
              width: 100,
              child: TextFormFieldBase(
                controller: dateController,
                readOnly: true,
                onTap: () async {
                  pickedStartDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedStartDate != null) {
                    DateTime date = pickedStartDate!.add(const Duration(hours: 12));
                    if (summitedDates.isEmpty) {
                      summitedDates.add(date);
                    } else {
                      summitedDates[0] = date;
                    }
                    MunroCompletion mc = MunroCompletion(
                      userId: userState.currentUser?.uid ?? "",
                      munroId: munro.id,
                      dateTimeCompleted: date,
                    );

                    bulkMunroUpdateState.updateMunroCompleted(mc);
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            )
          : null,
      onTap: () {
        if (summited) {
          bulkMunroUpdateState.removeMunroCompletion(munro.id);
        } else {
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day, 12, 0, 0, 0, 0);
          MunroCompletion mc = MunroCompletion(
            userId: userState.currentUser?.uid ?? "",
            munroId: munro.id,
            dateTimeCompleted: today,
          );

          bulkMunroUpdateState.addMunroCompleted(mc);
        }
      },
    );
  }
}
