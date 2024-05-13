import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/bulk_munro_updates/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class BulkMunroUpdateScreen extends StatefulWidget {
  static const String routeName = '/bulk_munro_update';
  const BulkMunroUpdateScreen({super.key});

  @override
  State<BulkMunroUpdateScreen> createState() => _BulkMunroUpdateScreenState();
}

class _BulkMunroUpdateScreenState extends State<BulkMunroUpdateScreen> {
  @override
  void initState() {
    super.initState();
    SharedPreferencesService.setShowBulkMunroDialog(false);
  }

  @override
  Widget build(BuildContext context) {
    BulkMunroUpdateState bulkMunroUpdateState = Provider.of<BulkMunroUpdateState>(context);
    MunroState munroState = Provider.of<MunroState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Munro Update'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              MunroService.bulkUpdateMunros(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
      body: ListView(children: [
        const BulkMunroSearchBar(),
        ...munroState.bulkMunroUpdateList.map((Munro munro) {
          Map<String, dynamic> e =
              bulkMunroUpdateState.bulkMunroUpdateList.firstWhere((element) => element[MunroFields.id] == munro.id);

          List<dynamic> summitedDates = e[MunroFields.summitedDates] as List<dynamic>;

          var firstSummitedDate = summitedDates.isEmpty ? null : summitedDates[0];
          if (firstSummitedDate != null) {
            if (firstSummitedDate is Timestamp) {
              firstSummitedDate = (firstSummitedDate).toDate();
            }
          } else {
            firstSummitedDate = DateTime.now();
          }

          TextEditingController dateController =
              TextEditingController(text: DateFormat('dd/MM/yy').format(firstSummitedDate));

          DateTime? pickedStartDate;
          return ListTile(
            title: Text(munro.name),
            subtitle: munro.extra != null ? Text(munro.extra!) : null,
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
        }),
      ]),
    );
  }
}
