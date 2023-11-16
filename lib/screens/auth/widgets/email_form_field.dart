import 'package:flutter/material.dart';

class EmailFormField extends StatelessWidget {
  final TextEditingController textEditingController;
  const EmailFormField({Key? key, required this.textEditingController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RegExp emailRegex =
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");

    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Email',
      ),
      textInputAction: TextInputAction.next,
      maxLines: 1,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      onSaved: (value) {
        textEditingController.text = value!.trim();
      },
    );
  }
}
