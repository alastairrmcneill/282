import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

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
  final Color? fillColor;

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
    this.fillColor,
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
      textAlignVertical: TextAlignVertical.top, // Add this line
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.all(10),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: border,
        filled: fillColor != null,
        fillColor: fillColor,
        hintStyle:
            Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w400, color: MyColors.mutedText),
      ),
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autocorrect: autocorrect,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w400),
    );
  }
}
