import 'package:flutter/material.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController textEditingController;
  final String? Function(String?)? validator;
  const PasswordFormField({Key? key, required this.textEditingController, this.validator}) : super(key: key);

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final RegExp passwordRegex = RegExp(r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z\d\s])[A-Za-z\d\W]{8,}$");
    return TextFormFieldBase(
      labelText: 'Password',
      suffixIcon: IconButton(
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        icon: _obscureText ? const Icon(Icons.visibility_off_rounded) : const Icon(Icons.visibility_rounded),
      ),
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      onChanged: (value) {
        widget.textEditingController.text = value;
      },
      validator: widget.validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            if (!passwordRegex.hasMatch(value)) {
              return 'Password must meet the requirements';
            }
            return null;
          },
      onSaved: (value) {
        widget.textEditingController.text = value!.trim();
      },
    );
  }
}
