import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class BasicSavedListNameInput extends StatefulWidget {
  final Function onCreate;
  final Function onCancel;

  const BasicSavedListNameInput({super.key, required this.onCreate, required this.onCancel});

  @override
  State<BasicSavedListNameInput> createState() => _BasicSavedListNameInputState();
}

class _BasicSavedListNameInputState extends State<BasicSavedListNameInput> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _cancel() {
    setState(() {
      _nameController.clear();
    });
    widget.onCancel();
  }

  Future<void> _createList() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    await context.read<SavedListState>().createSavedList(name: _nameController.text);

    if (!mounted) return;

    setState(() {
      _nameController.clear();
    });
    widget.onCreate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextFormField(
            controller: _nameController,
            hintText: 'List name...',
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
                child: SecondaryButton(
                  analyticsEvent: AnalyticsEvent.createSavedListCancel,
                  onPressed: _cancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  analyticsEvent: AnalyticsEvent.createSavedListCreate,
                  onPressed: _createList,
                  disabled: _nameController.text.trim().isEmpty,
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
