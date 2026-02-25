import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';

class CreateNewSavedListWidget extends StatefulWidget {
  const CreateNewSavedListWidget({super.key});

  @override
  State<CreateNewSavedListWidget> createState() => _CreateNewSavedListWidgetState();
}

class _CreateNewSavedListWidgetState extends State<CreateNewSavedListWidget> {
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    if (!_isCreating) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: OutlinedButton(
          onPressed: () => setState(() => _isCreating = true),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsBold.plus),
              const SizedBox(width: 8),
              Text('Create new list'),
            ],
          ),
        ),
      );
    }

    return SavedListNameInput(onCancel: () => setState(() => _isCreating = false));
  }
}
