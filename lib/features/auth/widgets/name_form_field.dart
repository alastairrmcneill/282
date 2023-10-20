import 'package:flutter/material.dart';

class NameFormField extends StatelessWidget {
  final String? hintText;
  final TextEditingController textEditingController;
  const NameFormField({Key? key, required this.textEditingController, this.hintText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: hintText ?? "Name",
      ),
      maxLines: 1,
      textCapitalization: TextCapitalization.words,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
      onSaved: (value) {
        textEditingController.text = value!.trim();
      },
    );
  }
}
