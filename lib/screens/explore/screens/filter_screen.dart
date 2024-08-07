import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final List<String> completedOptions = ['Yes', 'No'];
  final List<String> areaOptions = [
    "Angus",
    "Argyll",
    "Cairngorms",
    "Fort William",
    "Islands",
    "Kintail",
    "Loch Lomond",
    "Loch Ness",
    "Perthshire",
    "Sutherland",
    "Torridon",
    "Ullapool",
  ];

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
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Sort', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    RadioListTile(
                      title: const Text('Alphabetical'),
                      value: SortOrder.alphabetical,
                      groupValue: munroState.sortOrder,
                      onChanged: (value) => setState(() => munroState.setSortOrder = value!),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                    RadioListTile(
                      title: const Text('Height'),
                      value: SortOrder.height,
                      groupValue: munroState.sortOrder,
                      onChanged: (value) => setState(() => munroState.setSortOrder = value!),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                    RadioListTile(
                      title: const Text('Popular'),
                      value: SortOrder.popular,
                      groupValue: munroState.sortOrder,
                      onChanged: (value) => setState(() => munroState.setSortOrder = value!),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                    RadioListTile(
                      title: const Text('Rating'),
                      value: SortOrder.rating,
                      groupValue: munroState.sortOrder,
                      onChanged: (value) => setState(() => munroState.setSortOrder = value!),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                    const Divider(
                      endIndent: 16,
                      indent: 16,
                      thickness: 0.75,
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Completed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    ...completedOptions.map(
                      (String option) => CheckboxListTile(
                        value: munroState.filterOptions.completed.contains(option),
                        onChanged: (value) {
                          if (value == null) return;

                          FilterOptions options = munroState.filterOptions;

                          if (options.completed.contains(option)) {
                            options.completed.remove(option);
                            munroState.setFilterOptions = options;
                          } else {
                            options.completed.add(option);
                            munroState.setFilterOptions = options;
                          }

                          setState(() {});
                        },
                        title: Text(option),
                      ),
                    ),
                    const Divider(
                      endIndent: 16,
                      indent: 16,
                      thickness: 0.75,
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Areas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    ...areaOptions.map(
                      (String option) => CheckboxListTile(
                        value: munroState.filterOptions.areas.contains(option),
                        onChanged: (value) {
                          FilterOptions options = munroState.filterOptions;
                          if (options.areas.contains(option)) {
                            options.areas.remove(option);
                            munroState.setFilterOptions = options;
                          } else {
                            options.areas.add(option);
                            munroState.setFilterOptions = options;
                          }

                          setState(() {});
                        },
                        title: Text(option),
                      ),
                    ),
                    const Divider(
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
