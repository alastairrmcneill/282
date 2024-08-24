import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class FilterScreenSortOptions extends StatefulWidget {
  const FilterScreenSortOptions({super.key});

  @override
  State<FilterScreenSortOptions> createState() => _FilterScreenSortOptionsState();
}

class _FilterScreenSortOptionsState extends State<FilterScreenSortOptions> {
  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
