import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/bulk_munro_updates/widgets/widgets.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class BulkMunroUpdateScreen extends StatefulWidget {
  static const String route = '/bulk_munro_update';
  const BulkMunroUpdateScreen({super.key});

  @override
  State<BulkMunroUpdateScreen> createState() => _BulkMunroUpdateScreenState();
}

class _BulkMunroUpdateScreenState extends State<BulkMunroUpdateScreen> {
  final FocusNode searchFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    context.read<AppFlagsRepository>().setShowBulkMunroDialog(false);
  }

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final munroCompletionState = context.watch<MunroCompletionState>();
    final bulkMunroUpdateState = context.watch<BulkMunroUpdateState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Munro Update'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              munroCompletionState.addBulkCompletions(
                munroCompletions: bulkMunroUpdateState.addedMunroCompletions,
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
      body: ListView(children: [
        AppSearchBar(
          focusNode: searchFocusNode,
          hintText: "Search Munros",
          onSearchTap: () {},
          onChanged: (value) {
            munroState.setBulkMunroUpdateFilterString = value;
          },
          onClear: () {
            munroState.setBulkMunroUpdateFilterString = '';
          },
        ),
        ...munroState.bulkMunroUpdateList.map((Munro munro) {
          return BulkMunroUpdateListTile(munro: munro);
        }),
      ]),
    );
  }
}
