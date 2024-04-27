import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/bulk_munro_updates/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class BulkMunroUpdateScreen extends StatelessWidget {
  static const String routeName = '/bulk_munro_update';
  const BulkMunroUpdateScreen({super.key});

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

          return ListTile(
            title: Text(munro.name),
            subtitle: munro.extra != null ? Text(munro.extra!) : null,
            leading: e[MunroFields.summited] ? const Icon(Icons.check) : const SizedBox(),
            onTap: () {
              if (e[MunroFields.summited]) {
                bulkMunroUpdateState.setMunro = {
                  MunroFields.id: munro.id,
                  MunroFields.summited: !e[MunroFields.summited],
                  MunroFields.summitedDate: null,
                  MunroFields.summitedDates: []
                };
              } else {
                bulkMunroUpdateState.setMunro = {
                  MunroFields.id: munro.id,
                  MunroFields.summited: !e[MunroFields.summited],
                  MunroFields.summitedDate: DateTime.now(),
                  MunroFields.summitedDates: munro.summitedDates!.isEmpty ? [DateTime.now()] : munro.summitedDates!
                };
              }
            },
          );
        }).toList(),
      ]),
      // body: ListView(
      //   children: bulkMunroUpdateState.bulkMunroUpdateList.map(
      //     (e) {
      //       UserState userState = Provider.of<UserState>(context, listen: false);
      //       List<Map<String, dynamic>> personalMunroData = userState.currentUser!.personalMunroData!;

      //       Munro munro = munroState.munroList.firstWhere((element) => element.id == e[MunroFields.id]);

      //       return ListTile(
      //         title: Text(munro.name),
      //         subtitle: munro.extra != null ? Text(munro.extra!) : null,
      //         leading: e[MunroFields.summited] ? const Icon(Icons.check) : const SizedBox(),
      //         onTap: () {
      //           if (e[MunroFields.summited]) {
      //             bulkMunroUpdateState.setMunro = {
      //               MunroFields.id: munro.id,
      //               MunroFields.summited: !e[MunroFields.summited],
      //               MunroFields.summitedDate: null,
      //               MunroFields.summitedDates: []
      //             };
      //           } else {
      //             bulkMunroUpdateState.setMunro = {
      //               MunroFields.id: munro.id,
      //               MunroFields.summited: !e[MunroFields.summited],
      //               MunroFields.summitedDate: DateTime.now(),
      //               MunroFields.summitedDates: munro.summitedDates!.isEmpty ? [DateTime.now()] : munro.summitedDates!
      //             };
      //           }
      //         },
      //       );
      //     },
      //   ).toList(),
      // ),
    );
  }
}
