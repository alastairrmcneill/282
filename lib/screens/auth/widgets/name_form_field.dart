import 'package:flutter/material.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class NameFormField extends StatelessWidget {
  final String? hintText;
  final TextEditingController textEditingController;
  const NameFormField({Key? key, required this.textEditingController, this.hintText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormFieldBase(
      controller: textEditingController,
      hintText: hintText ?? "Name",
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
