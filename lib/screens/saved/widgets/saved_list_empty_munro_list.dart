import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class SavedListEmptyMunroList extends StatelessWidget {
  const SavedListEmptyMunroList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(
            PhosphorIconsRegular.mountains,
            color: context.colors.textMuted,
          ),
          Text(
            'No munros added yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
          )
        ],
      ),
    );
  }
}
