import 'package:flutter/material.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class BioFormField extends StatelessWidget {
  final String? hintText;
  final TextEditingController textEditingController;
  const BioFormField({Key? key, required this.textEditingController, this.hintText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormFieldBase(
      controller: textEditingController,
      hintText: "Bio",
      minLines: 4,
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
