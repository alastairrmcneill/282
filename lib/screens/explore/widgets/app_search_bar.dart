import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

class AppSearchBar extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback? onSearchTap;
  final Function(String)? onChanged;
  final VoidCallback onClear;
  final String hintText;
  const AppSearchBar(
      {super.key,
      required this.focusNode,
      this.onSearchTap,
      required this.onClear,
      this.onChanged,
      required this.hintText});

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: textEditingController,
        focusNode: widget.focusNode,
        autocorrect: false,
        onTap: widget.onSearchTap,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(
              color: MyColors.accentColor,
              width: 0.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(
              color: MyColors.accentColor,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(
              color: MyColors.accentColor,
              width: 0.5,
            ),
          ),
          suffixIcon: textEditingController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    CupertinoIcons.xmark,
                    color: MyColors.accentColor,
                    size: 18,
                  ),
                  onPressed: () {
                    textEditingController.clear();
                    widget.onClear();
                  },
                )
              : null,
        ),
        onChanged: widget.onChanged);
  }
}
