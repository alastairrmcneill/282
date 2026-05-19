import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class FilterScreenAreaGroup extends StatefulWidget {
  const FilterScreenAreaGroup({super.key});

  @override
  State<FilterScreenAreaGroup> createState() => _FilterScreenAreaGroupState();
}

class _FilterScreenAreaGroupState extends State<FilterScreenAreaGroup> {
  static const _areaOptions = [
    'Angus',
    'Argyll',
    'Cairngorms',
    'Fort William',
    'Islands',
    'Kintail',
    'Loch Lomond',
    'Loch Ness',
    'Perthshire',
    'Sutherland',
    'Torridon',
    'Ullapool',
  ];

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Areas', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _areaOptions.map((area) {
            final isSelected = munroState.filterOptions.areas.contains(area);
            return _AreaChip(
              label: area,
              isSelected: isSelected,
              onTap: () {
                final opts = FilterOptions()
                  ..completed = List.from(munroState.filterOptions.completed)
                  ..areas = List.from(munroState.filterOptions.areas);
                if (isSelected) {
                  opts.areas.remove(area);
                } else {
                  opts.areas.add(area);
                }
                munroState.setFilterOptions = opts;
                setState(() {});
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AreaChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AreaChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.accent : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? context.colors.accent : context.colors.border,
            width: 0.65,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : context.colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}
