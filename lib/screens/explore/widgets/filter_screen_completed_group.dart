import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class FilterScreenCompletedGroup extends StatefulWidget {
  const FilterScreenCompletedGroup({super.key});

  @override
  State<FilterScreenCompletedGroup> createState() => _FilterScreenCompletedGroupState();
}

class _FilterScreenCompletedGroupState extends State<FilterScreenCompletedGroup> {
  static const _options = [
    (value: '', label: 'All Munros'),
    (value: 'Yes', label: 'Completed'),
    (value: 'No', label: 'Not Completed'),
  ];

  String _currentValue(FilterOptions options) {
    final c = options.completed;
    if (c.length == 1 && c.contains('Yes')) return 'Yes';
    if (c.length == 1 && c.contains('No')) return 'No';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final current = _currentValue(munroState.filterOptions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Completion Status', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ...List.generate(_options.length, (i) {
          final option = _options[i];
          final isSelected = current == option.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _FilterOptionTile(
              label: option.label,
              isSelected: isSelected,
              onTap: () {
                final opts = FilterOptions()..areas = List.from(munroState.filterOptions.areas);
                if (option.value.isNotEmpty) opts.completed = [option.value];
                munroState.setFilterOptions = opts;
                setState(() {});
              },
            ),
          );
        }),
      ],
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isSelected ? context.colors.accent : context.colors.border,
            width: 0.65,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        color: isSelected ? context.colors.accent.withValues(alpha: 0.05) : Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isSelected ? context.colors.accent : context.colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.accent,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
