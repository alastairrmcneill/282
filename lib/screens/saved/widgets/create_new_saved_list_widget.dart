import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreateNewSavedListWidget extends StatefulWidget {
  const CreateNewSavedListWidget({super.key});

  @override
  State<CreateNewSavedListWidget> createState() => _CreateNewSavedListWidgetState();
}

class _CreateNewSavedListWidgetState extends State<CreateNewSavedListWidget> {
  bool _isCreating = false;
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startCreating() {
    setState(() {
      _isCreating = true;
      _nameController.clear();
    });
  }

  void _cancel() {
    setState(() {
      _isCreating = false;
      _nameController.clear();
    });
  }

  Future<void> _createList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    await context.read<SavedListState>().createSavedList(name: _nameController.text);
    
    if (!mounted) return;
    
    setState(() {
      _isCreating = false;
      _nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCreating) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: OutlinedButton(
          onPressed: _startCreating,
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

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormFieldBase(
                  controller: _nameController,
                  hintText: 'List name...',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: MyColors.lightGrey,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _nameController.text = value!;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancel,
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _createList,
                        child: const Text('Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
