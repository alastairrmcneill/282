import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class FilterScreenCompletedGroup extends StatefulWidget {
  const FilterScreenCompletedGroup({super.key});

  @override
  State<FilterScreenCompletedGroup> createState() => _FilterScreenCompletedGroupState();
}

class _FilterScreenCompletedGroupState extends State<FilterScreenCompletedGroup> {
  final List<String> completedOptions = ['Yes', 'No'];
  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
