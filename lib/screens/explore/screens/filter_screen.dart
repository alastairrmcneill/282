import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});
  static const String route = '${ExploreTab.route}/filter';

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    FilterScreenSortOptions(),
                    Divider(
                      endIndent: 16,
                      indent: 16,
                      thickness: 0.75,
                    ),
                    SizedBox(height: 10),
                    FilterScreenCompletedGroup(),
                    Divider(
                      endIndent: 16,
                      indent: 16,
                      thickness: 0.75,
                    ),
                    SizedBox(height: 10),
                    FilterScreenAreaGroup(),
                    Divider(
                      endIndent: 16,
                      indent: 16,
                      thickness: 0.75,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      munroState.setFilterOptions = FilterOptions();
                      munroState.setSortOrder = SortOrder.alphabetical;
                      setState(() {});
                    },
                    child: const Text("Clear"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                        "Show ${munroState.filteredMunroList.length} ${munroState.filteredMunroList.length == 1 ? "Munro" : "Munros"}"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
