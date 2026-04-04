import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class TextFormFieldBase extends StatelessWidget {
  final TextEditingController? controller;
  final ScrollController? scrollController;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final Future Function()? onTap;
  final int maxLines;
  final int? minLines;
  final bool readOnly;
  final String? hintText;
  final String? labelText;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextInputType keyboardType;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool autocorrect;
  final InputBorder? border;
  final Color fillColor;

  const TextFormFieldBase({
    super.key,
    this.controller,
    this.scrollController,
    this.initialValue,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.minLines,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.hintText,
    this.labelText,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.textInputAction,
    this.autocorrect = true,
    this.border,
    this.fillColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        scrollController: scrollController,
        initialValue: initialValue,
        onSaved: onSaved,
        validator: validator,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.all(10),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: border ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: context.colors.textMuted,
                  width: 0.7,
                ),
              ),
          enabledBorder: border ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: context.colors.textMuted,
                  width: 0.7,
                ),
              ),
          focusedBorder: border ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: context.colors.accent,
                  width: 1.2,
                ),
              ),
          filled: true,
          fillColor: fillColor,
          hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: context.colors.textMuted,
              ),
        ),
        textCapitalization: textCapitalization,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autocorrect: autocorrect,
        style: Theme.of(context).textTheme.bodyLarge);
  }
}
