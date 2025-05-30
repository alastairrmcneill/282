import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/bulk_munro_updates/widgets/widgets.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

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
    SharedPreferencesService.setShowBulkMunroDialog(false);
  }

  @override
  Widget build(BuildContext context) {
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
        AppSearchBar(
          focusNode: searchFocusNode,
          hintText: "Search Munros",
          onSearchTap: () {},
          onChanged: (value) {
            munroState.setFilterString = value;
          },
          onClear: () {
            munroState.setFilterString = ''; // Chanhge to friends
          },
        ),
        ...munroState.filteredMunroList.map((Munro munro) {
          return BulkMunroUpdateListTile(munro: munro);
        }),
      ]),
    );
  }
}
