import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class FilterScreenAreaGroup extends StatefulWidget {
  const FilterScreenAreaGroup({super.key});

  @override
  State<FilterScreenAreaGroup> createState() => _FilterScreenAreaGroupState();
}

class _FilterScreenAreaGroupState extends State<FilterScreenAreaGroup> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
