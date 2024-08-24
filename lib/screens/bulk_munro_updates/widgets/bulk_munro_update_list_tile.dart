import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class BulkMunroUpdateListTile extends StatelessWidget {
  final Munro munro;
  const BulkMunroUpdateListTile({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    BulkMunroUpdateState bulkMunroUpdateState = Provider.of<BulkMunroUpdateState>(context);

    // Find element element in bulkMunroUpdateList
    Map<String, dynamic> e =
        bulkMunroUpdateState.bulkMunroUpdateList.firstWhere((element) => element[MunroFields.id] == munro.id);

    // Get summited dates from this element
    List<dynamic> summitedDates = e[MunroFields.summitedDates] as List<dynamic>;

    // Figure out what the first summited date is
    var firstSummitedDate = summitedDates.isEmpty ? null : summitedDates[0];
    if (firstSummitedDate != null) {
      if (firstSummitedDate is Timestamp) {
        firstSummitedDate = (firstSummitedDate).toDate();
      }
    } else {
      firstSummitedDate = DateTime.now();
    }

    // Write that date into the date controller
    TextEditingController dateController =
        TextEditingController(text: DateFormat('dd/MM/yy').format(firstSummitedDate));

    DateTime? pickedStartDate;

    return ListTile(
      title: Text(munro.name),
      subtitle: Text("${munro.extra == null || munro.extra!.isEmpty ? "" : "${munro.extra} · "}${munro.area}"),
      leading: e[MunroFields.summited] ? const Icon(Icons.check) : const SizedBox(),
      trailing: e[MunroFields.summited]
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
                    if (munro.summitedDates!.isEmpty) {
                      munro.summitedDates!.add(date);
                    } else {
                      munro.summitedDates![0] = date;
                    }
                    bulkMunroUpdateState.setMunro = {
                      MunroFields.id: munro.id,
                      MunroFields.summitedDates: munro.summitedDates,
                    };
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
        if (e[MunroFields.summited]) {
          bulkMunroUpdateState.setMunro = {
            MunroFields.id: munro.id,
            MunroFields.summited: !e[MunroFields.summited],
            MunroFields.summitedDate: null,
            MunroFields.summitedDates: []
          };
        } else {
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day, 12, 0, 0, 0, 0);
          bulkMunroUpdateState.setMunro = {
            MunroFields.id: munro.id,
            MunroFields.summited: !e[MunroFields.summited],
            MunroFields.summitedDate: today,
            MunroFields.summitedDates: munro.summitedDates!.isEmpty ? [today] : munro.summitedDates!
          };
        }
      },
    );
  }
}
