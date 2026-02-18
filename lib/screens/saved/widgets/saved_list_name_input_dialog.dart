import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

// Show dialog to add historical entry to an account
showCreateSavedListDialog(BuildContext context, {SavedList? savedList}) {
  TextEditingController nameController = TextEditingController(text: savedList?.name);
  final formKey = GlobalKey<FormState>();

  Future submitForm() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();

    if (savedList == null) {
      await context
          .read<SavedListState>()
          .createSavedList(name: nameController.text)
          .whenComplete(() => Navigator.pop(context));
      return;
    } else {
      SavedList newSavedList = savedList.copy(name: nameController.text);
      await context
          .read<SavedListState>()
          .updateSavedListName(savedList: newSavedList)
          .whenComplete(() => Navigator.pop(context));
    }
  }

  AlertDialog alert = AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    content: StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Form
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Title
                    Text(savedList == null ? 'Create new list' : 'Edit list'),
                    const SizedBox(height: 20),
                    TextFormFieldBase(
                      controller: nameController,
                      labelText: 'Name',
                      border: const OutlineInputBorder(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        nameController.text = value!;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit form button
              SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await submitForm();
                  },
                  child: const Text('Save'),
                ),
              )
            ],
          ),
        );
      },
    ),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
