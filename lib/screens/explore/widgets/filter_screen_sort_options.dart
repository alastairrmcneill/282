import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class FilterScreenSortOptions extends StatefulWidget {
  const FilterScreenSortOptions({super.key});

  @override
  State<FilterScreenSortOptions> createState() => _FilterScreenSortOptionsState();
}

class _FilterScreenSortOptionsState extends State<FilterScreenSortOptions> {
  static const _options = [
    (value: SortOrder.alphabetical, label: 'Alphabetical'),
    (value: SortOrder.height, label: 'Height'),
    (value: SortOrder.rating, label: 'Rating'),
    (value: SortOrder.popular, label: 'Most Popular'),
  ];

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sort By', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ...List.generate(_options.length, (i) {
          final option = _options[i];
          final isSelected = munroState.sortOrder == option.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _FilterOptionTile(
              label: option.label,
              isSelected: isSelected,
              onTap: () => setState(() => munroState.setSortOrder = option.value),
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
