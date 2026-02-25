import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/screens/saved/widgets/saved_list_name_input.dart';
import 'package:two_eight_two/support/theme.dart';

class EmptySavedListScreen extends StatefulWidget {
  const EmptySavedListScreen({super.key});

  @override
  State<EmptySavedListScreen> createState() => _EmptySavedListScreenState();
}

class _EmptySavedListScreenState extends State<EmptySavedListScreen> {
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isCreating) {
      return SavedListNameInput(onCancel: () => setState(() => _isCreating = false));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 120),
          Container(
            decoration: BoxDecoration(
              color: MyColors.lightGrey,
              shape: BoxShape.circle,
            ),
            width: 90,
            height: 90,
            child: Icon(
              PhosphorIconsRegular.listDashes,
              size: 40,
              color: MyColors.mutedText,
            ),
          ),
          const SizedBox(height: 40),
          Text('Start Planning Your Journey', style: textTheme.titleLarge),
          const SizedBox(height: 20),
          Text(
            'Create custom lists to organize munros by region, difficulty, or your personal goals. Track your progress and plan your next adventure.',
            style: textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          FilledButton(
            onPressed: () => setState(() => _isCreating = true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsBold.plus),
                const SizedBox(width: 8),
                Text('Create your first list'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
