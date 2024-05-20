// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ConfirmPasswordFormField extends StatefulWidget {
  final TextEditingController confirmPassword_TextEditingController;
  final TextEditingController password_TextEditingController;
  const ConfirmPasswordFormField({
    Key? key,
    required this.confirmPassword_TextEditingController,
    required this.password_TextEditingController,
  }) : super(key: key);

  @override
  State<ConfirmPasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<ConfirmPasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormFieldBase(
      labelText: 'Confirm Password',
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
        widget.confirmPassword_TextEditingController.text = value;
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        if (widget.password_TextEditingController.text != value.trim()) {
          return 'Passwords must match';
        }
        return null;
      },
      onSaved: (value) {
        widget.confirmPassword_TextEditingController.text = value!.trim();
      },
    );
  }
}
