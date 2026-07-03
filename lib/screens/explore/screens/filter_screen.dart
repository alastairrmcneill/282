import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/sort_order.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});
  static const String route = '${ExploreTab.route}/filter';

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final hasActiveFilters = munroState.sortOrder != SortOrder.alphabetical ||
        munroState.filterOptions.completed.isNotEmpty ||
        munroState.filterOptions.areas.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter & Sort'),
        actions: [
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  munroState.setFilterOptions = FilterOptions();
                  munroState.setSortOrder = SortOrder.alphabetical;
                  setState(() {});
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(color: context.colors.accent),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterScreenSortOptions(),
            SizedBox(height: 24),
            FilterScreenCompletedGroup(),
            SizedBox(height: 24),
            FilterScreenAreaGroup(),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _ApplyButton(munroState: munroState),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final MunroState munroState;
  const _ApplyButton({required this.munroState});

  @override
  Widget build(BuildContext context) {
    final count = munroState.filteredMunroList.length;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border:
            Border(top: BorderSide(color: context.colors.border, width: 0.65)),
      ),
      child: BottomButtonBar(
        child: CtaButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Show $count ${count == 1 ? "Munro" : "Munros"}'),
        ),
      ),
    );
  }
}
