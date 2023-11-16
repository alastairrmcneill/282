import 'package:flutter/material.dart';

class BioFormField extends StatelessWidget {
  final String? hintText;
  final TextEditingController textEditingController;
  const BioFormField({Key? key, required this.textEditingController, this.hintText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: hintText ?? "Bio",
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.all(15),
      ),
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.text,
      maxLength: 100,
      onSaved: (value) {
        textEditingController.text = value!.trim();
      },
    );
  }
}
