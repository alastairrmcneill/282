import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';

class SavedListNameInput extends StatefulWidget {
  final Function onCreate;
  final Function onCancel;
  const SavedListNameInput({super.key, required this.onCreate, required this.onCancel});

  @override
  State<SavedListNameInput> createState() => _SavedListNameInputState();
}

class _SavedListNameInputState extends State<SavedListNameInput> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BasicSavedListNameInput(
          onCreate: () => widget.onCreate(),
          onCancel: () => widget.onCancel(),
        ),
      ),
    );
  }
}
